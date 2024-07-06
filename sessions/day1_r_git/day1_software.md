---
marp: true
title: Necessary and useful packages and software
_class: invert
footer: SICSS Berlin - Day 1 - 2024/07/08
size: 16:9
paginate: true
_paginate: false
math: mathjax
headingDivider: 1
---

# Installation: **Quarto**

On Tuesday and Wednesday, we are going to use Quarto Markdown Documents, instead of R scripts. Quarto should be pre-installed in RStudio. Please check whether it is by opening the file "day1_r_git/quarto_testfile.qmd" with RStudio. 

Also make sure that you see the "Source" and "Visual" buttons in the top left (see image).

![](img/quarto_selection.png)

If it is not installed, please update your RStudio version!

# Installation: **RSelenium**

You will need to follow the steps described in this [Video](https://www.youtube.com/watch?v=GnpJujF9dBw).

For Apple users: 

- When selecting the "Architecture" for the Java SDK on https://www.azul.com/downloads/, you need to know which version to choose. You find that out by pressing the Apple button and selecting "About this Mac". Here you either have M1 or M2, which means you select "Arm 64 bit", or you have Intel, in which you select "x86 64 bit".

- To find the libray: Click finder --> Click Go/Gehe zu (top of screen) --> Press Option/Wahltaste --> Now you can see library, select it!

For Everyone:

- The chromedrivers that RSelenium downloads are outdated, you will have to download an up to date chromedriver yourself. Check the version of your Chrome browser, and then download the matching chromedriver from here: https://googlechromelabs.github.io/chrome-for-testing/. See this video for a step-by-step guide: https://www.youtube.com/watch?v=BnY4PZyL9cg. 



```r
install.packages(c("RSelenium", "wdman", "netstat", "binman"))

library(RSelenium)
library(wdman)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)
```

---


```r
binman::list_versions("chromedriver")

# The following command should open a browser window (you might need to adjust the version!)
remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.127",
                          verbose = FALSE,
                          port = free_port())

                       
# close the server
remote_driver$server$stop()

# If you start it a few times, but never close the server there might be no empty port left.
# You can run the following to kill all java processes
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
```

If you manage to start your chrome browser with the above script, RSelenium is installed properly.

# Installion: **Python Anaconda**

- Anaconda is a free and open-source distribution of the Python programming language
- includes also Jupyter Notebooks, Conda (Package Manager) and over 1500 pre-installed data science related packages
- will be useful to interact with LLM models with Python (from RStudio)

Decide which one to download:
- [Anaconda](https://www.anaconda.com/download/success) (extensive and effortless)
- [Miniconda](https://docs.anaconda.com/free/miniconda/) (slim and customizable)


# Code Editor: **VSCode**

![h:530 drop-shadow:0,10px,20px,rgba(0,0,0,.4)](img/r_vscode.png)


# Code Editor: **Benefits**

- Swiss army knife for coding and file management
  - search (and replace) in whole project folder
  - side-by-side editor windows
  - better file and folder management
  - customizable (with extensions)
- multiple languages supported (e.g. R, Python, Notebooks, LaTeX, Markdown)
- easy Git(Hub) integration for better workflow
- with R:
  - run multiple R Sessions in parallel
  - scripts still editable if process is busy


# Code Editor: **Resources**

- https://code.visualstudio.com/docs/languages/r
- https://renkun.me/2019/12/11/writing-r-in-vscode-a-fresh-start/
- https://schiff.co.nz/blog/r-and-vscode/
- https://rolkra.github.io/R-VSCode/
