let printf = require("printf");
let readlineSync = require("readline-sync");
let main = () => {
    let str = new Array(100);
    while (1) {
        process.stdout.write(printf("Please enter a non-empty string less than 100 character, terminated by an enter key:\n"));
        str = readlineSync.question('').split('');
        if (str != "") {
            break;
        }
    }
    let i = 0;
    let total = str.length - 1;
    let flag = 1;
    for (i = 0;i <= total; i++) {
        if (str[i] != str[total - i]) {
            // not a palindromic string
            flag = 0;
            break;
        }
    }
    if (flag == 1) {
        process.stdout.write(printf("True\n"));
    } else {
        process.stdout.write(printf("False\n"));
    }
    return 0;
}
main();