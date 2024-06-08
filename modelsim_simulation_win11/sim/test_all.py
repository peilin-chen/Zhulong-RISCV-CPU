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

def main():
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))
    # 获取路径下所有bin文件
    all_bin_files = list_binfiles(rtl_dir + r'/sim/generated/')
    # 遍历所有文件一个一个执行
    total = 0
    correct = 0
    wrong = 0
    for file_bin in all_bin_files:
        cmd = r'python compile_and_sim.py' + ' ' + file_bin
        f = os.popen(cmd)
        r = f.read()

        total = total + 1

        index = file_bin.index('-p-')
        print_name = file_bin[index+3:-4]

        if (r.find('passed') != -1):
            print('指令  ' + print_name.ljust(10, ' ') + '    PASS')
            correct = correct + 1
        else:
            print('指令  ' + print_name.ljust(10, ' ') + '    !!!FAIL!!!')
            wrong = wrong + 1
        f.close()
    print("###########Summary###########")
    print("Correct instructions:", correct)
    print("Wrong   instructions:", wrong)
    print("Overall instructions:", total)

if __name__ == '__main__':
    main()