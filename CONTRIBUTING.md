# CONTRIBUTING

## Sharing  is Good

Code needs to be shared. Developers need to know that they  can get to your
code not only now, but in the future.
Two tools for that are licenses and DOIs.

### Open Source Licenses

To add a license to your repo, add a  [LICENSE.md](https://github.com/timm/keys/blob/main/LICENSE.md)
file to the root of your repo.

Open source licenses are licenses that comply with the Open Source Definition— 
in brief, they allow software to be freely used, modified, and shared. 

There are many different kinds of license and there are [on-line tools](https://choosealicense.com)
to help you decide which one is right for you.

- Choose anything you like but be aware the 
  [more esoteric you get](http://www.wtfpl.net), the fewer people will use your code.
- In practice, most folks using the MIT license or (if you are worried
  about patent trolls) the Apache license. 
  - The former is preferred for lightweight projects while the latter 
    requires a lot of documentation. 
  - E.g. see how much work goes into the [Zehyphr release notes](https://github.com/zephyrproject-rtos/zephyr/releases/tag/zephyr-v2.5.0) 
    (and Zephyr uses the Apache license).


### Long Term Storage, Cite-able

Your repo needs a "digital object idenitifier" badge that assigns a unique ID
to your code _and_ which backs up a copy of the code to some long term storage. 
To check for that badge, look for something like:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4728990.svg)](https://doi.org/10.5281/zenodo.4728990)

This badge makes the code "cite-able".
Github repos are temporary, they  can be deleted. Developers need to
registered their repo at some long-term storage facility  like Zenodo. There:

- It you make a release in Github
- Zenodo will grab a zipped copy and store it on its
hard drives (somewhere in Switzerland) and issues you with a "DOI" (digital object
identifier) 

For notes on that process, see [here](http://guides.github.com/activities/citable-code/).
