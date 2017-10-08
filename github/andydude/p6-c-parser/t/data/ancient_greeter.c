int printf(const char *, ...);

int main(argc, argv)
    int argc; char * argv[];
{
    printf("Hello %s!", argv[1]);
    return 0;
}
