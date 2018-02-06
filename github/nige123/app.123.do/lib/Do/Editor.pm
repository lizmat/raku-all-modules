class Do::Editor {

    method open ($filename, $line-number = 1) {
        # use jmp to open the user's preferred editor at a specific line
        return run 'jmp', 'edit', $filename, $line-number;
    }   
}

