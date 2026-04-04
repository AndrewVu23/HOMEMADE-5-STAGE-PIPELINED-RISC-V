import os
import logging

import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class homemade_rv32i(pluginTemplate):
    __model__ = "homemade_rv32i"
    __version__ = "1.0.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs.get('config')
        if config is None:
            raise SystemExit("Missing config for homemade_rv32i plugin.")

        self.pluginpath = os.path.abspath(config['pluginpath'])
        self.isa_spec = os.path.abspath(config['ispec'])
        self.platform_spec = os.path.abspath(config['pspec'])
        self.num_jobs = str(config.get('jobs', 1))

        if 'target_run' in config and config['target_run'] == '0':
            self.target_run = False
        else:
            self.target_run = True

        # Path to the processor RTL source directory (repo root, two levels up from this file)
        self.rtl_dir = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '../..'))

    def initialise(self, suite, work_dir, archtest_env):
        self.work_dir = work_dir
        self.suite_dir = suite

        # Compile command template:
        # {0} = march, {1} = test .S file, {2} = output elf, {3} = compile macros
        # Always use riscv64-unknown-elf-gcc (it supports -march=rv32i cross-compilation)
        # -mno-relax is CRITICAL: prevents linker from inserting compressed instructions
        self.compile_cmd = (
            'riscv64-unknown-elf-gcc -march={0} -mno-relax '
            '-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g '
            '-T ' + self.pluginpath + '/env/link.ld '
            '-I ' + self.pluginpath + '/env/ '
            '-I ' + archtest_env + ' {1} -o {2} {3}'
        )

    def build(self, isa_yaml, platform_yaml):
        ispec = utils.load_yaml(isa_yaml)['hart0']
        self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')

        # Build march string from ISA spec
        self.isa = 'rv' + self.xlen
        if "I" in ispec["ISA"]:
            self.isa += 'i'
        if "M" in ispec["ISA"]:
            self.isa += 'm'
        if "F" in ispec["ISA"]:
            self.isa += 'f'
        if "D" in ispec["ISA"]:
            self.isa += 'd'
        if "C" in ispec["ISA"]:
            self.isa += 'c'

        self.compile_cmd = self.compile_cmd + ' -mabi=' + (
            'lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')

    def runTests(self, testList):
        # Delete old Makefile if it exists
        makefile_path = os.path.join(self.work_dir, "Makefile." + self.name[:-1])
        if os.path.exists(makefile_path):
            os.remove(makefile_path)

        make = utils.makeUtil(makefilePath=makefile_path)
        make.makeCommand = 'make -k -j' + self.num_jobs

        for testname in testList:
            testentry = testList[testname]
            test = testentry['test_path']
            test_dir = testentry['work_dir']
            elf = 'my.elf'
            sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
            compile_macros = ' -D' + " -D".join(testentry['macros'])

            # 1. Compile the test
            cmd = self.compile_cmd.format(
                testentry['isa'].lower(), test, elf, compile_macros)

            # 2. Convert ELF to binary, then to word-level hex for $readmemh
            # objcopy -O verilog produces byte-level hex, but our memories are word arrays
            # So we go ELF -> binary -> word-level hex via a python one-liner
            bin_cmd = (
                'riscv64-unknown-elf-objcopy -O binary {0} firmware.bin'
            ).format(elf)

            hex_convert_cmd = (
                "python3 -c \""
                "data=open('firmware.bin','rb').read();"
                "f=open('firmware.hex','w');"
                "[f.write('%08x\\n'%int.from_bytes(data[i:i+4],'little'))for i in range(0,len(data),4)];"
                "f.close()\""
            )

            # 3. Extract begin_signature, end_signature, and tohost addresses from ELF
            # Note: $$ escapes to $ in Makefiles
            extract_sig_cmd = (
                "begin_sig=$$(riscv64-unknown-elf-nm {0} | grep 'begin_signature' | awk '{{print $$1}}') && "
                "end_sig=$$(riscv64-unknown-elf-nm {0} | grep 'end_signature' | awk '{{print $$1}}') && "
                "tohost_addr=$$(riscv64-unknown-elf-nm {0} | grep ' tohost$$' | awk '{{print $$1}}')"
            ).format(elf)

            # 4. Run iverilog simulation
            src_files = ' '.join([
                os.path.join(self.rtl_dir, 'pkg/signals_pkg.sv'),
                os.path.join(self.rtl_dir, 'src/*.sv'),
                os.path.join(self.rtl_dir, 'tb/Riscof_tb.sv'),
            ])
            sim_compile = (
                'iverilog -g2012 -I {0}/pkg -o sim.vvp {1}'
            ).format(self.rtl_dir, src_files)

            sim_run = (
                'vvp sim.vvp +firmware=firmware.hex '
                '+begin_signature=0x$${{begin_sig}} '
                '+end_signature=0x$${{end_sig}} '
                '+tohost_addr=0x$${{tohost_addr}} '
                '+signature_file={0}'
            ).format(sig_file)

            if self.target_run:
                execute = '@cd {0}; {1}; {2}; {3}; {4}; {5}; {6};'.format(
                    test_dir, cmd, bin_cmd, hex_convert_cmd, extract_sig_cmd,
                    sim_compile, sim_run)
            else:
                execute = '@cd {0}; {1};'.format(test_dir, cmd)

            make.add_target(execute)

        make.execute_all(self.work_dir)

        if not self.target_run:
            raise SystemExit(0)
