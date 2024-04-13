import os
import sys

if __name__ == "__main__":
    if len(sys.argv) < 2:
        os._exit(1)

    cnt = 0
    all_git_repos_txt = sys.argv[1]

    print(f'scanning all git repos in this computer...')

    with open(all_git_repos_txt, 'wb') as f:
        for driver in range(ord("A"), ord("A") + 26):
            driver = chr(driver) + ":\\"
            if not os.path.exists(driver):
                continue
            for root, folders, files in os.walk(driver):
                if '$recycle.bin' in root.lower():
                    continue
                for folder in folders:
                    if folder == '.git':
                        cnt += 1
                        f.write(f'{root}\n'.encode('utf-8'))
                        break

    print(f'{cnt} Done!')
    os.system("pause")
