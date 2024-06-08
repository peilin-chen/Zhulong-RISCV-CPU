import os
import subprocess
import sys

def list_binfiles(path):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.bin'):
                files.append(apath)

    return files

def bin_to_mem(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))
    datafile = open(outfile, 'w')

    index = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0

    for b in  binfile_content:
        if index == 0:
            b0 = b
            index = index + 1
        elif index == 1:
            b1 = b
            index = index + 1
        elif index == 2:
            b2 = b
            index = index + 1
        elif index == 3:
            b3 = b
            index = 0
            array = []
            array.append(b3)
            array.append(b2)
            array.append(b1)
            array.append(b0)
            datafile.write(bytearray(array).hex() + '\n')

    binfile.close()
    datafile.close()

def compile():
    iverilog_cmd = ['vsim']
    iverilog_cmd += ['-c']
    iverilog_cmd += ['-do', r'simulate.do']
    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=50)

def sim():
    compile()

def run(test_binfile):
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))
    # 文件名字
    out_mem = rtl_dir + r'/sim/generated/inst_data.txt'
    # bin 转 mem
    bin_to_mem(test_binfile, out_mem)
    # 运行仿真
    sim()

if __name__ == '__main__':
    sys.exit(run(sys.argv[1]))