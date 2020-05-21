# Preference Allocation
[![Travis-CI Build Status](https://travis-ci.org/avisionh/Preference-Allocation.svg?branch=master)](https://travis-ci.org/avisionh/Preference-Allocation)

### Collaborators

- [Avision Ho](https://github.com/avisionh)
- [Le Duong](https://github.com/ledu1993)


# Update
- A Shiny app is being built for this problem.
- The project management and code development of this stage will be captured on [Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/). 
    - Compared to GitHub, this has superior project management capabilities.
- Link to this can be found on the [public project page, Preference Allocation](https://avisionh.visualstudio.com/Preference%20Allocation).

***

# Background
The problem we will tackle in this repository is of *preference allocation*/*one-sided matching*.

## Task
Consider that we have to assign *x* people to *y* sessions. For each of these *y* sessions,
and individual person will have a preference ordering, meaning that they strictly prefer some sessions over others.

The task is to allocate these *x* people to their *y* sessions, accounting for their preferences
in such a way that the total utility of all *x* people is maximised.

## Aim/Motivation
- [x] Write an algorithm that automates the matching/mapping of one set to another set given pre-defined constraints.
- [ ] Write effective functions, include error-trapping and -handling.
- [ ] Build a Shiny app that makes this algorithm accessible to non-programmers.
- [ ] Host the Shiny app on a public domain, [shinyapp.io](https://www.shinyapps.io/).
- [ ] Demonstrate a consistent R coding and Git workflow usage.
- [ ] Implement a CI/CD pipeline to robustly and continuously test whether the code works on different operating systems (OS) using [travis-ci](https://travis-ci.org/) and [Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/).
- [ ] Adopt an Agile project management approach using [Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/) to capture and efficiently manage feature requests.
- [ ] Conduct user-research to continuously improve the algorithm and Shiny app.

# Case Study
This algorithm was used in the [GSS Conference 2018](https://gss.civilservice.gov.uk/events/gss-conference-2018/) to allocate a set of 400 conference delegates to a series of talks that were taking place at the same time. 

These talks were delivered by internal government and external private sector companies.

In total, there were four sessions of five simultaneous talks. As such, this algorithm was run four times to produce matchings between delegates and these five simultaneous talks.

**Note:** The rooms in which the speakers delivered their presentations were not pre-allocated. Instead, the decision to place more popular talks (based on people's preferences) in larger rooms was based on plotting the distribution of preferences for the five simultaneous talks for all delegates.

# Methodology
We will tackle this problem in two ways:
1. **Gale-Shapley Algorithm |** Implementation of Alvin Roth and Lloyd Shapley's algorithm that assigns delegates to sessions in random order by accounting for both their preferences and ensuring that no two matching pairs will mutually want to switch their matches.
1. **Iterative Preference |** Implementation of a method suggested by a work experience student, Fatma Hussain, this takes chooses delegates and assigns them their n-th most preferred session provided the session is available. 
***

## References
- [The Stable Marriage Problem and School Choice](http://www.ams.org/publicoutreach/feature-column/fc-2015-03)
- [Gale-Shapley algorithm](https://www.nobelprize.org/nobel_prizes/economic-sciences/laureates/2012/popular-economicsciences2012.pdf)
- [matchingR](https://cran.r-project.org/web/packages/matchingR/vignettes/matchingR-intro.html)

