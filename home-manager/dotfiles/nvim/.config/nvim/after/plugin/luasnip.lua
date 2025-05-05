local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

ls.add_snippets("apex", {
    s({
        trig = 'header',
        desc = 'Gives a formatted apex header for every class type',
        name = 'Apex Class Header',
    },
    fmt(
        [[
        /******************************************************************************
        Author:{}
        Test Class(s):{}
        Description:{}
        Created:{}
        ******************************************************************************/
        ]],{i(1,'Ryan O\'Sullivan'),i(2),i(3),os.date('%Y-%m-%d')}
    )),
    s({
        trig = 'fori',
        desc = 'For loop with a integer',
        name = 'For Integer loop'
    },
    fmt(
        [[
        for( Integer {i} = 0 ; {i} {l} {c}, {i}++){{
        \{o}
        }}
        ]], 
        {
            i = i(1,'i'),
            l = i(2,'<'),
            c = i(3),
            o = i(0)
        },
        {
            indent_string = '\\',
            repeat_duplicates = true
        }
    )),
    s({
        trig = 'forl',
        desc = 'For loop with a list of records',
        name = 'For List loop'
    },
    fmt(
        [[
        for( {t} {n}: {l}){{
        \{o}
        }}
        ]],
        {
            t = i(1,'Account'),
            n = i(2,'oAcct'),
            l = i(3,'accounts'),
            o = i(0),
        },
        {
            indent_string = '\\'
        }
    )),
    s({
        trig = 'testMeth',
        desc = 'Starts a Test method for ApexTest',
        name = 'Apex Test Method'
    },
    fmt(
        [[
        @isTest
        private static void {t}(){{
        \{o}
        }}
        ]],
        {
            t = i(1,'default_test_name'),
            o = i(0),
        },
        {
            indent_string = '\\'
        }
    )),
    s({
            trig = 'list',
            desc = 'Intiates a list in apex',
            name = 'New List'
    },
    fmt(
        [[
        List<{o}> {n} = new List<{o}>{c};
        ]],
                {
                    n = i(2,'accountList'),
                    o = i(1,'Account'),
                    c = c(3,{
                        t("()"),
                        sn(nil, {t("{"),i(1), t("}")})
                    })
                },
                {
                    indent_string = '\\'
                }
    )),
    s({
        trig = 'soql',
        desc = 'Starts a query in apex',
        name = 'Apex SOQL'
    },
    fmt(
        [[
        [
        \SELECT Id,
        \{f}
        \FROM {o}
        \{w} {c}
        ];{e}
        ]],
        {
            f = i(1),
            o = i(2,'Account'),
            w = i(3,'WHERE'),
            c = i(4),
            e = i(0)
        },
        {
            indent_string = '\\'
        }
    ))
})
