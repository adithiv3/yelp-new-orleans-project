# AI prompts used in this project

I used Claude as a tutor and coding assistant. The AI drafted code and explanations; I ran every piece of code myself, reported errors and output back, checked the results, and made the choices about the theme, the geographic system, the reviewer threshold, and my conclusions. Below are the exchanges that mattered most, with what I checked and how I re-prompted.


## 1. Importing the huge JSON files

**My prompt (shortened):**
> Step 1 and 2 for Project 2: 1. Create a new GitHub directory 2. Download the large files, unzip them and load them into R 3. Filter for New Orleans 4. Save as RDS file (then you can delete the raw files if you are running out of room)

**What the AI gave me:** A step-by-step plan and an R script. The script read the small business file normally but streamed the 5 GB review file in chunks of 100,000 reviews with `jsonlite::stream_in()`, keeping only reviews for New Orleans restaurants so the full file never has to fit in memory.

**Problem I found:** After I clicked Source, R stopped with `Error in print.default(m, ...)`.

**My re-prompt:** I pasted the error and described what I did.

**Result:** The AI traced it to my diagnostic `print()` lines, which assumed tibbles, and gave a version that converted the data to tibbles. The script then ran: 150,346 businesses, 2,259 New Orleans restaurants, 6,990,280 reviews streamed, and 476,421 reviews kept.

**What I checked:** I compared the review counts with Yelp's `review_count` field (476,421 reviews in the file versus 465,982 reported), confirmed that every restaurant had reviews, and confirmed that the saved `.rds` files loaded and were small enough for GitHub (117 KB, 8.7 MB, and 78 MB for the version with text, which I left out of the repo).

## 2. Extracting the download

**My prompt (shortened):**
> when I do this in my terminal, this is what it says: unzip: cannot find or open Yelp-JSON.zip... zsh: command not found: adjust ... tar: yelp_dataset.tar: m: No such file or directory

**What the AI gave me:** An explanation that the downloaded file name contained a space (so it needed quotes), and that my terminal had tried to run the `#` comments that were on the same line as the commands. It gave comment-free commands and a way to list the files first.

**Result:** I extracted only the business and review JSON files, and `ls -lh` showed the 113 MB and 5.0 GB files.

## 3. Running exploration code in the wrong file

**My prompt (shortened):**
> I tried to run the following inside R/01_import_and_filter.R ... Error: object 'category_counts' not found. When I run the entire file without this part, here is the error: Error: file.exists(business_file) is not TRUE

**What the AI gave me:** The first error happened because `category_counts` is created in the report, not in the import script. The second error was expected because I had deleted the raw files, and the `.rds` files already held the filtered data. It gave me code to run in the Console that loads the saved `.rds` and builds the category counts.

**Result:** I got the full list of 300 categories.

## 4. Choosing a theme with evidence

**My prompts:** I pasted my category counts and asked which categories fit together (first desserts, ice cream, and bakeries; then I proposed dietary restrictions with halal, vegetarian, and vegan).

**What the AI gave me:** A comparison of candidate themes: how many restaurants, how many ZIP codes, how many reviews, and how many reviewers had five or more reviews. It warned that halal is small (11 restaurants) and that Yelp categories do not verify dietary practices.

**My decision:** I chose the dietary theme (halal, vegetarian, vegan): 125 restaurants in 12 ZIP areas. I proposed this theme myself, and the AI checked whether the data could support it. I chose it over the sweet-treats theme because it answers a practical question for diners, and the group was large enough, well above the minimum of 10 restaurants in 7 areas.

## 5. Reviewing my Step 3-6 report against the instructions

**My prompt:** I uploaded my rendered report and asked whether I had finished Steps 3-6.

**What the AI gave me:** Specific gaps against the instructions: a plot for each geographic system I tested (I only had a ZIP map), an explanation of the unmatched restaurant, an explicit statement that I met the requirement of 10 restaurants in 7 areas, a definition of "best", and map problems (the city map was mostly empty because it was not zoomed to the restaurants; the ZIP map had no labels).

**What I did:** I added the area-size plot, the unmatched-restaurant table, labels and a city outline on the ZIP map, and a zoomed map. I also added a sentence stating that the group meets the requirement (125 restaurants in 12 ZIP areas), defined "best" in my research question, and used the unmatched table to find that the one unmatched restaurant (City Greens) is in Jefferson Parish, outside the Orleans Parish tract boundaries.

## 6. Designing the reviewer-adjusted analysis (Step 7)

**My prompt:** I asked for help finishing the remaining steps.

**What the AI gave me:** Code that counts reviewers at several activity thresholds, computes each reviewer's mean baseline, subtracts it from each rating, and ranks restaurants. It added a shrinkage rule so small samples cannot dominate the ranking, and it warned that most reviewers in the group have only one or two reviews.

**What I checked:** I read the threshold table: requiring at least 2 reviews in the selected group keeps 3,433 reviewers (34.4% of reviews), 3 keeps 1,224 (19.4%), 5 keeps 350 (9.6%, or 2,820 reviews), and 10 keeps only 76 (3.9%). With a threshold of 5, 99 of the 125 restaurants have at least five eligible reviews, so they can be ranked. I checked that the mean-based and median-based adjusted restaurant scores agree (correlation 0.949), so the choice of baseline does not change the picture. I also looked at the raw top 10, which is led by restaurants with very few reviews (Viva Las Vegan has 5 reviews and a perfect 5.0), which showed why a minimum number of reviews was needed. Finally, I looked at which restaurants move most between the raw and adjusted rankings (Green To Go from 81st to 4th, Catalino's from 5th to 63rd) and noticed that several large movers rest on only 6 to 14 eligible reviews.

**My decision:** I kept the minimum at 5 reviews, the suggested starting point. At 2 or 3 reviews, a reviewer's baseline comes from too few ratings to say much about how they usually rate. At 10, only 76 reviewers remain, too few to rank most restaurants. At 5, enough reviewers remain (350) for 99 of 125 restaurants to be ranked. The cost is that the adjusted analysis uses only 9.6% of the reviews, so I present it as a complement to the raw ratings, not a replacement, and I discuss that limitation in the report.

## 7. Final check of my report

**My prompt:** I uploaded my rendered report and asked whether it was complete and correct.

**What the AI gave me:** It confirmed that the report ran and that the numbers were consistent. It also noticed that seven of my top 10 restaurants rest on only 5 to 10 eligible reviews, so the ranking is fragile, and it suggested a stability check on the top 10. It found leftover figure files from an older draft and a formatting problem in how I had pasted a section.

**What I did:** I ran a stability check that re-ranked the restaurants under five alternative settings (a minimum of 5 or 10 eligible reviews, and 5, 10, or 20 pseudo-reviews of shrinkage) and counted how many of my original top 10 stayed in the top 10. I built the report so that this count, and the list of restaurants that stay in the top 10 under every setting, are computed from the results and filled into the text automatically, and I describe the top 10 as strong leads and not an exact ranking. I also deleted four leftover figures from an older draft, fixed a section I had pasted as a bullet instead of a heading, and confirmed that `.quarto/` was already in my `.gitignore`.

## 8. Making the charts easier to read

**My prompt:** I asked for chart titles that are bold and larger, and for the other text in the charts to look different, so people can tell what is a title.

**What the AI gave me:** A shared `theme_report()` function (bold, larger titles; italic subtitles; bold axis and legend titles) and a `sed` command to switch every plot to it.

**Problem I found:** I ran the `sed` command in the R Console and got `Error: unexpected string constant`.

**What I did:** The AI explained that `sed` is a shell command and belongs in the Terminal tab. I re-ran it there, confirmed with `grep` that six plots were switched, and re-rendered the report. The titles are now bold.

## What I learned about using AI

* AI code can have bugs that only appear when I run it, so I ran each step, pasted exact errors back, and checked results against the data (for example, review counts against Yelp's counts).
* Pasting the exact error message or the output gets a much better answer than describing the problem.
* Asking the AI to compare options with data (the theme-comparison table) was better than asking it to pick for me.