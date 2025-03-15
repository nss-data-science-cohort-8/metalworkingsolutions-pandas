# branch management

this should be a fairly good outline of branch management for working in groups with GitHub.

## new issues - new branches
**when you are ready to work on a new issue:**

1. make sure you have no uncommitted work on your current branch before you check out new branch.

2. consider the changes / part of the project you're going to be working on, and either select the issue from the project or create an issue in the project and assign it to yourself.

3. open the issue by clicking the text. in the bottom right, you'll see "create a branch" in the "Development" panel. Click that.

4. assign a name to the branch (github will suggest one for you, feel free to use that, or change it to an acceptable name).

5. select the repository of destination (your working repo) and branch source.
  - the branch source will be the files that are included in your new branch.
6. If you select check out locally, github will give you the terminal commands to run to checkout your new issue branch.

7. navigate to your repository directory on your local system and run those commands to fetch the new changes and checkout your new branch. *it's a good idea to only work on your issue branch for the time being, and don't make changes to your source branch to avoid merge conflicts.*
   **don't forget that when you're pushing to a branch it's a good idea to be in the habit of including the origin in your push, i.e. `git push origin branch_name`.

## issue complete - merging branches & pull requests
**when you are finished working on your issue:**

1. commit all your changes and push them to your branch using `git push origin branch_name`.

2. on GitHub navigate to your issue branch. you should see a button at the top that says 'Compare & pull request' in a highlighted bar that says something like '`branch_name` had recent pushes 25 seconds ago' 

3. click on that button. double check at the top under 'Comparing changes' that your base repository is the correct repo and that the base branch is the branch you want to merge to, i.e. your source branch. 

4. write a detailed description of your changes / work you have committed to the issue branch. 

5. click 'Create pull request', allow to load, then click 'merge pull request'. This works fine when you're working on your own projects, but when working professionally you may not be the one merging the pull request, but a supervisor or the repository maintainer. 
**don't forget that after you have pushed and merged your changes back into the source branch, the next time you checkout that source branch you should pull the changes with `git pull origin source_branch` before making new changes. 
