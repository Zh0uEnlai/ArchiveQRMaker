from .archiver import pmain
from .args import get_args

def main():
    args = get_args()
    url = args.url
    if url is None:
        print("Bruhg you ")
    create_dir = args.create_dir
    pmain(url, create_dir)


if __name__ == "__main__":
   main()