If you run in trouble with GitHub and you can't pull because of a merge conflict, you can try the following:

1. Just to be safe, make a copy of all your local changes (private exercise folder)
2. enter the following commands in the terminal in RStudio:

```git
git fetch origin
git reset --hard origin/master
```

3. If necessary, re-add your copied files, commit and push again