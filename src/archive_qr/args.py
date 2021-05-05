import sys
from argparse import ArgumentParser

def get_args():

    description = f"""
    Takes a URL, archives it, then saves it as a QRcode, optionally creating a directory in the process.

    {sys.argv[0]} https://www.marxists.org -n # Creates a QR code for the website, archiving it as well, saving the result to a new directory.
    """
    parser = ArgumentParser(description=description)

    parser.add_argument("url", help="The URL to archive and create a Quick Response (QR) code.", type=str)
    parser.add_argument("-n", dest="create_dir", help="Whether to create a new directory for the qrcode and archive. This creates a directory named after the original url in reverse-DNS notation (e.g. org.marxists.title", type=bool)
    
    return parser.parse_args()
    # args.create_dir