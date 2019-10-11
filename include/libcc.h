/* Skelix by Xiaoming Mo (skelixos@gmail.com)
 * Licence: GPLv2 */
#ifndef LIBCC_H
#define LIBCC_H

#define NULL	((void *)0)

void bcopy(const void *src, void *dest, unsigned int n);
void bzero(void *dest, unsigned int n);
void *memcpy(void *dest, const void *src, unsigned int n);
void *memset(void *dest, int c, unsigned int n);
int memcmp(const void *s1, const void *s2, unsigned int n);
int strcmp(const char *s1, const char *s2);
char *strcpy(char *dest, const char *src);
unsigned int strlen(const char *s);

#define assert(s) do { if (! (s)) {	\
kprintf(KPL_PANIC, "ASSERT: %s, %d", __FILE__, __LINE__);	\
halt();	\
}} while (0)

#define SLEEP(t)                                                               \
  do {                                                                         \
    long PI = 0, a = 2, b = 1, c = 0, sn = 1;                                  \
    int n = 10000 * t;                                                       \
    for (int i = 1; i <= n; i++) {                                             \
      sn = sn * a / b;                                                         \
      c = a;                                                                   \
      a = b + 1;                                                               \
      b = c + 1;                                                               \
      PI = 2 * sn;                                                             \
    }                                                                          \
  } while (0)
  
#endif
