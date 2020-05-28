# Steps for testing locally

## Recommended setup (requires Docker)
> ## Prerequisites:
> - docker should be installed

1. cd to project root
2. run `docker-compose up`

That's it!

Now, wait for it to build, index some packages and start the server.

After the server is up and running, you can use: <a>http://localhost:3000/api/packages/?query=</a> to search the packages.

# Problem Statement

Create an application to fetch & index package details from a CRAN server.
Also, create a search API to search packages by name.

----

CRAN is a network of ftp and web servers around the world that store identical, up-to-date, versions of code and documentation for R. The R project uses these CRAN Servers to store R packages.

Every CRAN server contains a plain file listing all the packages in that server which can be accessed using this URL: ​http://cran.r-project.org/src/contrib/PACKAGES

### Format of PACKAGES file

[...]

Package: adehabitatHR

Version: 0.4.2

Depends: R (>= 2.10.0), sp, methods, deldir, ade4, adehabitatMA, adehabitatLT Suggests: maptools, tkrplot, MASS, rgeos, gpclib

License: GPL (>= 2)

[...]

### Package URL format

You can build the URL of every R package as:
> http://cran.rproject.org/src/contrib/[PACKAGE_NAME]_[PACKAGE_VERSION].tar.gz

Example Package URL:
> http://cran.r-project.org/src/contrib/shape_1.4.1.tar.gz

Inside every package, after you uncompress it, there is a file called DESCRIPTION where you can get some extra information about the package.
