# CONTRIBUTING

## Sharing  is Good

The best code is used by the best people.
The more code is shared, the more we all benefit from that work.

For code to be shared:

- It must be under version control.
- It must be unencumbered of  propitiatory licenses.
  Hence, you need an **open source license**. 
- It must be accessible for now and for all time in the future.
  Your code needs to be **mirrored** 
  in some long-term, cite-able, repository.
- It needs to be  trusted by the community. This means that it needs a good
  **test suite**.
- It needs to be effectively **documented**.

## Version Control.

Git. Enough  said. Just do it.

## Open Source Licenses

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


## Long Term Storage, Cite-able

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

## Unit Tests

Your repo needs a [.travis.yml](https://github.com/timm/keys/blob/main/.travis.yml)
that adds a "post-commit hook" to the  repo. This hook runs a test suite each time
the code is committed. This, in turn, updates a badge on your repo that  tells people
your code has  tests and those tests are working.

[![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)

To code the test suite, you need something that runs and returns 
the shell flag _$?=0_ (if there 
are no errors) or _$?&gt;0_ (if errors were found). This is simple- just have a demo
suite that does some asserts. If those asserts fail, your code will crash  and set
_$?&gt;0_.

As to how to write the test suite, there are any number of unit test tools.
And its easy to write your own. For example, the  test suite here  is inside
[./src/eg.lua](https://github.com/timm/keys/blob/main/src/eg.lua). This code can be called in
three ways:

- `cd src; ./eg.lua` which just runs everything;
- `cd src; ./eg.lua ?` which lists all the  available tests;
- `cd src; ./eg.lua xxx` which runs just test `xxx`. This last call
  is very handy when writing and debugging just on example.

## Documentation

Code needs to be understood. It needs pretty prints that shows comments with the code.
There are  any number of tools for that purpose. Here:

- We create a directory `./docs` containing a file `./docs/.nojeykll`;
- Then we use the `pycco` took to fill up that directory with html files
  that describe the code.
- Then we tell Github to serve `./docs` as a website (see  
  see https://github.com/yourName/yourProject/settings/pages).

