# Generate modules classpath

This script adds to the Liferay eclipse project all `src` directories from OSGi modules 

## Installation
Just copy the sh files to your system

You can also add the following line to your system aliases:

   * `alias generate_modules_classpath='curl https://raw.githubusercontent.com/jorgediaz-lr/generate-modules-classpath/master/generate_modules_classpath.sh | bash'`

(thanks to Cleydyr de Albuquerque for this idea)

For Windows users: you can launch the script using git bash, [WSL](https://docs.microsoft.com/en-us/windows/wsl/install), [Cygwin](https://www.cygwin.com/) or [MinGw](http://www.mingw.org/)

## Usage
1. Important: Before using the script, it is advisable to execute `ant all` to download all `jar` dependencies
2. Execute `/path/generate_modules_classpath.sh [project-directory]`
   * project-directory: directory where eclipse project is located. (optional parameter, the current directory by default)
3. You can also use the "curl" approach explained above:
   * execute previously defined alias: `generate_modules_classpath`
   * or execute the full command: `curl https://raw.githubusercontent.com/jorgediaz-lr/generate-modules-classpath/master/generate_modules_classpath.sh | bash`
4. The script will make a backup of original eclipse `.classpath` in `.classpath_backup` and `.classpath` will be populated with all src and jar files from OSGi modules
5. Open eclipse and execute a refresh+clean of the project

In case you also want to add tests classes to the classpath, use `generate_modules_classpath_all.sh`
 
## Result
You will see all src modules and you will be able to find any Liferay class from modules

![](screenshot_eclipse.png)
