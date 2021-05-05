import sys
import ssl 
import http

import os
from pathlib import Path
from contextlib import suppress
from urllib.parse import urlparse

from requests.models import PreparedRequest


import pyqrcode
from selenium import webdriver
from selenium.webdriver.support.ui import Select, WebDriverWait
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

def upload_image_to_image_bb(browser, image_filepath, upload_wait_time=5):
    browser.get("https://imgbox.com/")

    # Reference: https://www.guru99.com/upload-download-file-selenium-webdriver.htm\=]
    element = browser.find_element_by_name("files[]")
    element.send_keys(os.path.abspath(image_filepath))

    # mark the content type as adult.
    dropdown = browser.find_element_by_css_selector('[data-id="dropdown-content-type"]')
    dropdown.click()

    # The list of all dropdown options.
    dropdown_buttons = browser.find_elements_by_css_selector("a[tabindex=\"0\"]")

    # Mark the content type as adult.
    (dropdown_buttons[2]).click()

    # Set Thumbnail size
    dropdown = browser.find_element_by_css_selector('[data-id="thumbnail-option"]')
    dropdown.click()
    (dropdown_buttons[18]).click()

    # Set Allow Comments (to off)
    dropdown = browser.find_element_by_css_selector('[data-id="comments-option"]')
    dropdown.click()
    (dropdown_buttons[20]).click() # Disable comments

    # Don't create a new gallery
    dropdown = browser.find_element_by_css_selector('[data-id="gallery-option"]')
    dropdown.click()
    (dropdown_buttons[22]).click() # No gallery

    # Click submit on the fake upload button, which triggers the real upload button
    browser.find_element_by_css_selector("#fake-submit-button").click()

    # Wait for the upload to finish
    try:
        wait_until = EC.presence_of_element_located((By.CLASS_NAME, "tc_f"))

        WebDriverWait(browser, upload_wait_time).until(wait_until) # I don't want to wait for the redirect.
    except TimeoutException:
       # Expected until we implement smart redirect-detection logic.
        print("\n\n\n\nFUCKKKKKKKKKKK")
    time.sleep(upload_wait_time)

    ### On the post-upload page

    # Now let's get the image links.

    # Choose full-size links

    try:
        browser.find_element_by_css_selector(".tc_f").click()
    except NoSuchElementException:
        pass

    # raw link
    bb_code = browser.find_element_by_css_selector("textarea#code-bb-full").text

    # gets the actual raw image link (directly to the image, instead of a proxy)
    image_link = re.search(r"\[IMG\](.*?)\[\/IMG\]", bb_code).group(1)
    # [URL=http://imgbox.com/dHuY9AVD][IMG]https://images2.imgbox.com/47/10/dHuY9AVD_o.jpg[/IMG][/URL]

    # Grab the deletion link, in case somebody wants to delete later.
    deletion_link = browser.find_element_by_css_selector("a[href*='/upload/']").text
    imagebox_result = ImageboxLink(image_link, bb_code, deletion_link)
    return imagebox_result



def save_as_qr(data: str, destination_directory: os.PathLike, filename: str):
    """Saves data as a Quick Response (QR) code in SVG format.
    We're using SVG for portability, plus vector graphics can be sized
    arbitrarily.

    Parameters
    ----------
    data : str
        The data to encode as a Quick Response (QR) code. 
        Usually this is just a URL string (e.g. https://www.marxists.org).
    destination_directory : os.PathLike
        Directory of where to store the final QR code file. This can be a string, or
        a pathlike object (created through Python's built-in pathlib module).
    filename : str
        What to name the final file.
    """
    return

def get_archive_today_link(url: str) -> str:
    """Creates an archive.today link from a given url [1].
    This link can be opened in your browser to finalize the 
    archive link creation (this often involves solving a captcha).

    [1] - https://archive.ph/faq

    Parameters
    ----------
    url : str
        The URL to archive with archive.today

    Returns
    -------
    str
        A URL that can be opened in the browser to finalize the archive creation.
    """
    archive_today_base_url = "https://archive.ph/"
    req = PreparedRequest()
    params = { "url" : url }
    req.prepare_url(archive_today_base_url, params)
    return req.url 


def get_archive_url(url: str):
    """Gets an Archive.Today url for a url. 
    This 

    Parameters
    ----------
    url : str
        [description]

    Returns
    -------
    [type]
        [description]
    """

    # Expand for other archivers, if ever necessary.
    archive_link = get_archive_today_link(url)
    return archive_link


def archive(url: str) -> str:

    # Make sure your have the Gecko driver installed and searchable in your PATH variable.
    firefox_profile = webdriver.FirefoxProfile()
    firefox_profile.set_preference("browser.privatebrowsing.autostart", True) # Technically unncessary, but I'm paranoid.

    browser = webdriver.Firefox(firefox_profile=firefox_profile)

    # You gotta solve the Captcha manually in the browser tab that's created, but
    # that's a fair trade-off for free website archiving, to be honest.

    archive_url = get_archive_url(url)
    browser.get(archive_url)

    with suppress(NoSuchElementException):
        browser.find_element_by_css_selector("#submiturl").click()


    webdriver.implicitly_wait(100)

    return "yeet"


    # 1) Archive the URL

    # 1.1) (Optional) Create a directory (named in reverse-DNS notation e.g. com-vox-dang_this_place_is_racist )) to store the results

    # 2) Create a QR code for the archived URL. 


def get_reverse_dns_prefix(url: str) -> str:
    """Creates a reverse dns prefix from a url. 
    e.g. Takes in 
    https://www.nytimes.com/2021/05/04/nyregion/new-york-reopening-reaction.html

    and spits out 

    "com.nytimes"

    Parameters
    ----------
    url : str
        URL to get the reverse-DNS prefix for.

    Returns
    -------
    str
        The reverse-DNS'ed url host name (e.g. com.nytimes)
    """
    # Gets rid of the "www." from the host.
    dns = urlparse(url).netloc.replace("www.", "")

    reverse_dns = ".".join(dns.split(".")[::-1])
    return reverse_dns

def get_filename_from_url(url: str) -> str:
    """Creates a filesystem-friendly file name from a url.

    Parameters
    ----------
    url : str
        URL for which to create a subdirectory.

    Returns
    -------
    str
        A filesystem-friendly file name, created from the url.
        
        e.g. From 'https://www.nytimes.com/2021/05/04/nyregion/new-york-reopening-reaction.html'
        
        to '2021_05_04_nyregion_new-york-reopening-reaction.html'
    """
    # Takes the last path component from a url.
    # e.g. takes    
    # 'https://www.nytimes.com/2021/05/04/nyregion/new-york-reopening-reaction.html'
    # 
    # Results in "new-york-reopening-reaction.html"
    #
    article_filename = Path(urlparse(url).path).name

    # Converts 
    #
    # '/2021/05/04/nyregion/new-york-reopening-reaction.html'
    #
    # to 
    #
    # ('/', '2021', '05', '04', 'nyregion', 'new-york-reopening-reaction.html')
    # 
    article_path = Path(urlparse(url).path)
    
    # Then strips off the root "/".
    path_without_root = article_path.parts[1:]

    # Joins the path parts into the final string, e.g. '2021_05_04_nyregion_new-york-reopening-reaction.html'
    filename = "_".join(path_without_root)
    return filename


def create_subdir(url: str) -> str:
    # Move to your stash.
    directory = Path(get_reverse_dns_prefix(url))
    with suppress(FileExistsError):
        directory.mkdir(exists_ok=True)

    # Base filename without an extension.
    base_filename = ".".join(dir_name, get_filename_from_url(url))

    # Move to the directory.
    os.chdir(directory.resolve())



def pmain(url, create_dir):
    if create_dir:
        create_subdir(url)
    archive(url)