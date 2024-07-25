# Installation guide and first steps
Based on [official tutorial](https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in)

Also check [Hercules doc](https://www.cica.es/wp-content/uploads/2024/06/Manual-de-usuario-Cl%C3%BAster-Hercules-CICA.pdf)

## Installation
### Download and unpack
1. Create yard/apps di
```
mkdir yard
pwd
cd yard
mkdir apps
```
2. Go to the Cell Ranger Download page and fill out the "10x Genomics End User Software License Agreement" information. Select either the Gzip or Xzip tarball to download. Be sure to copy the whole command from the Downloads page.
3. List the contents of the apps directory to see the Cell Ranger "tarball" (archive of files) with `ls -1`
4. Unpack the tarball with `tar -zxvf cellranger-x.y.z.tar.gz` or `tar -xvf cellranger-x.y.z.tar.xz`

### Add cell ranger to `$path`
1. Go to the cellranger dir
```
cd cellranger-x.y.z
pwd
```
2. `export PATH=/mnt/home/user.name/yard/apps/cellranger-x.y.z:$PATH`
3. `which cellranger`
4. For convenience, you may want to add this command to your .bashrc file, a special script that runs every time you log in to your system

## Perform a sitecheck
1. `cellranger sitecheck > sitecheck.txt`
2. `less sitecheck.txt`
3. Analyze the results based on requirements. Check [official support](https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in#sitecheck)
4. Tweaks may be required ie `ulimit -n 16000`. You may contact system administrator.

## Perform a test run
```console
cellranger testrun --id=check_install

```
should end with
```console
Waiting 6 seconds for UI to do final refresh.
Pipestance completed successfully!
2022-01-04 12:51:02 Shutting down.
```