#!/usr/bin/env bash
#
# Add "set display_filter='/path/to/this/script'" to your .muttrc
# You can also set it for your Jira mail folder with folder hook
#
# If you are using virtual-mailboxes, then, folder-hook will need a special tag
# (bugzilla-hook-filter) in the query to match this mailbox. This is because
# folder-hook doesn't match on the label ("bugzilla")
# virtual-mailboxes "bugzilla" "notmuch://?query=tag:bugzilla-hook-filter or (tag:bugzilla)"
#
# # Reset display filter for all
# folder-hook . "set display_filter=''"
# # Set filter for Jira/Bugzilla folder
# folder-hook bugzilla-hook-filter "set display_filter='/path/to/this/script'"

awk '
BEGIN {header=1; flag=1}

# First empty line, header is complete, ignore further lines (flag=0)
/^$/ {if (header==1) {header=0; flag=0}}

# But we want to print URL
/http[s]?:\/\/(www\.)?([^:]+).*/ {print "\n" $0}

# JIRA bullshit ends with this line, start printing further lines
/------------------------------/{flag=1; next}

# This is footer, lets also ignore it
/==============================/{next}
/This message was sent by Atlassian Jira/{flag=0} flag
' -
