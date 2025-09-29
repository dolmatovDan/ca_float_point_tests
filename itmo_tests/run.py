import subprocess
import csv

path_to_exe = "../../mathcs-ca-25-floating-point-dolmatovDan/main"

with open("true_gen_float_+-_tests.tsv", 'r', encoding='utf-8') as file:
    tsv_file = csv.reader(file, delimiter=",")
    passed = []
    failed = []
    error = []
    for line in tsv_file:
        if len(line) != 2:
            continue
        arr = line[0].split()
        if len(arr) == 5:
            if arr[3] == '*':
                arr[3] = "\\*"
            correct = " ".join([arr[0], arr[1], arr[3], arr[2], arr[4]])
        else:
            correct = line[0]
        process = subprocess.run(f"{path_to_exe} {correct}", shell=True, capture_output=True, text=True)
        stdout = process.stdout
        stderr = process.stderr

        print("--------------------")
        print(f"Test: {correct}", end="")
        if stderr:
            print(f"\n\033[91mError: {stderr}\033[0m")
            error.append(f"{line[0]}")
            continue
        if stdout.strip() == line[1].strip():
            print(f" \033[92mPass\033[0m")
            print(f"Output: {stdout}")
            passed.append(f"{line[0]}")
        else:
            print(f" \033[91mFail\033[0m")
            print(f"Anwser: {line[1]}")
            print(f"Output: {stdout}")
            failed.append(f"{line[0]}")
    print("Passed:", len(passed), "tests; failed", len(failed), "tests; error in", len(error), "tests.")
