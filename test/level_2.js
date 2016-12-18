let printf = require("printf");
let readlineSync = require("readline-sync");
let main = () => {
    let source = new Array(100);
    let target = new Array(100);
    // get a non-empty source string
    while (1) {
        process.stdout.write(printf("Please enter a non-empty source string less than 100 characters, terminated by an enter key:\n"));
        source = readlineSync.question('').split('');
        if (source != "") {
            break;
        }
    }
    // get a non-empty target string
    while (1) {
        process.stdout.write(printf("Please enter a target string less than 100 characters:\n"));
        target = readlineSync.question('').split('');
        if (target != "") {
            break;
        }
    }
    let source_len = source.length;
    let target_len = target.length;
    let k = -1;
    let z = 0;
    let next_pose = new Array(100);
    next_pose[0] = -1;
    /* calculate next_pos array for the target string */
    while (z < target_len) {
        if ((k == -1) || (target[z] == target[k])) {
            k = k + 1;
            z = z + 1;
            next_pose[z] = k;
        } else {
            k = next_pose[k];
        }
    }
    let i = 0;
    let j = 0;
    let flag = 0;
    while (1) {
        while ((i < source_len) && (j < target_len)) {
            if ((j == -1) || source[i] == target[j]) {
                i = i + 1;
                j = j + 1;
            } else {
                j = next_pose[j];
            }
        }
        /* matched the target string ! */
        if (j == target_len) {
            if (flag == 0) {
                // matched for the first time
                // not print comma
                process.stdout.write(printf("%d", i - target_len));
                flag = 1;
            } else {
                // otherwise print comma
                process.stdout.write(printf(",%d", i - target_len));
            }
            j = 0;
        } else {
            break;
        }
    }
    if (flag == 0) {
        process.stdout.write(printf("False\n"));
    } else {
        process.stdout.write(printf("\n"));
    }
    return 0;
}
main();