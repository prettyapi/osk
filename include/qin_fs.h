#ifndef QIN_FS_H
#define QIN_FS_H

#define NAME_LEN 30

struct qin_fs_inode {
    unsigned int type; //1:file, 2:dir, 3:block, 4:char, 5:pipe
    unsigned int izone;
};

struct qin_fs_super_block {
    unsigned short s_node;
};

//512/32=16个
struct qin_fs_dir_entry {
    unsigned short inode;
    unsigned char name[NAME_LEN];
};

char *kread(char *pathname, int length);
int kwrite(char *pathname, char *content);

#endif
