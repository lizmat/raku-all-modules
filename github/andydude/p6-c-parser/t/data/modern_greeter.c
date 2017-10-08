int printf(const char * restrict, ...);

int main(int argc, char * argv[]) {
    printf("Hello %s!", argv[1]);
    return 0;
}
