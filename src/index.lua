#!/usr/bin/env lua
-- vim: ts=2 sw=2 et :

-- Keys optimizer     
-- Tim Menzies, (c) 2021        

-- -----------------------------
-- ## Files
-- Unit tests:
-- 
-- - [eg](eg.html): test code. 
--   - If "`lua eg.lua`" returns $?=0, then all tests pass.
--   - To run one test, use "`lua eg.lua testname`". 
--   - To get a list of all tests, use   "`lua eg.lua ?`".
-- 
-- How to hold and summarize  data:
-- 
-- - [num](num.html) : for numerics
-- - [row](row.html) : place to hold rows, and their  column summaries
-- - [skip](skip.html) : "summarize" by ignoring everything  you throw at it
-- - [some](some.lua): reservoir sampler (keep a random sample)
-- - [sym](sym.lua) : for symbols
-- 
-- Utilities:
-- 
-- - [lib](lib.html) : misc utils
-- - [new](new.html)  : template for new files
-- - [rand](rand.html) : random number generator
--  -[stats](stats.html): statistical routines
-- 
-- Work in progress:
-- 
-- - [cli](cli.html)
-- 
-- -------------------
-- ## About
-- In two papers about _DUO_ (data miners using/used-by optimizers),
-- Agrawal, Fu, Markus, Mathew, Menzies, Minku, Nair, Markus Wagner, and Yu 
-- argued that _optimization_ and _data mining_ were very closely relate; i.e.
-- miners divide up a space;
-- while optimizers suggest ways to move to better parts of that space.
--
-- Missing in that paper was a reference implementation showing how to achieve all that. `KEYS` is that reference system. It is offered here as a learning guide for
-- those interested in data mining and optimization. 
--
-- ## An Invitation
-- `KEYS` is very short (a few 100 lines of code) and written in a 
-- very simple Python-like language (LUA). 
--
-- You are invited to recode `KEYS` in your favorite language.
-- To start with, the file `eg.lua` offers unit tests. 
-- It is suggested that you start at the top of that file and code up 
-- the first example. Once you can passes that test, move to the second example. And so on.
--
-- But more that that,
-- when implementing this system, we challenge you to
-- do better than what is offered here. 
-- ``KEYS` made short-cuts to simplify the code.
-- Some of those simplifications demonstrate interesting insights into the nature of data mining and optimization. 
-- But some are those simplifications are just plain silly. 
-- So your goal should be  to find and fix the silly bits. 
--
-- Good luck! Write a better `KEYS`! You can do it!
--
-- ## Why Study `KEYS`?
-- By combining the two technologies, said Agrawal et al., 
-- it is possible for data miners to help optimizers (and vice versa)
--
-- - _Transparency_ : After optimizing,  data miners can generate succinct rules that 
--   summarize optimizer output. This is an very important, especially in this era
--   where AI is mistrusted and there are increasing demands 
--   for understandable AI (https://youtu.be/uaaC57tcci0);
-- - _Focus_ : Before optimizing, data miners can divide up a problem. This makes  optimizers run faster since they are focusing on smaller, more specific problems;
-- - _Tuning_ : Before data mining, optimizers can find  better parameter settings for a data miner, 
-- - _Advice_ : After data mining, optimizers can take the learned model and use it to suggest how to improve some current situation.
-- - _Simplicity_ : under the hood, data miners and optimizers share many of the same data structures. So, if done
--   right, once you've coded and optimizer you are half way to a data miner (and vice versa).
--
-- ## References
-- - Vivek Nair, Amritanshu Agrawal, Jianfeng Chen, Wei Fu, George Mathew, Tim Menzies, Leandro Minku, Markus Wagner, and Zhe Yu. 2018. Data-driven search-based software engineering. In Proceedings of the 15th International Conference on Mining Software Repositories (MSR '18). Association for Computing Machinery, New York, NY, USA, 341–352. DOI:https://doi.org/10.1145/3196398.3196442
-- - Agrawal, A., Menzies, T., Minku, L. L., Wagner, M., & Yu, Z. (2020). Better software analytics via “DUO”: Data mining algorithms using/used-by optimizers. Empirical Software Engineering, 25(3), 2099-2136.


