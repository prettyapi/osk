#include <qin_fs.h>
#include <stdio.h>
#include <stdlib.h>

#define ROOT_INODE 1
#define INVALID_INODE -1

typedef short INODE;

INODE find_dir_entry(char *path, INODE cur_inode);

char *kread(char *f, int length) {}

int kwrite(char *pathname, char *content) {
    if (pathname == NULL) {
        return -1;
    }
    return INVALID_INODE;
}

INODE find_dir_entry(char *path, INODE cur_inode) {
    if (path[0] == '\0') {
        return cur_inode;
    }
    if (path[0] == '/') {
        return find_dir_entry(++path, ROOT_INODE);
    }
    
    return find_dir_entry(path, cur_inode);
}

int main(int argc, char const *argv[]) {
    char *path = "/data/wen/txt.data";
    INODE inode = find_dir_entry(path, 0);
    printf("find inode = %d\n", inode);
    return 0;
}
