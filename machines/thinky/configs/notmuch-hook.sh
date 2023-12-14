#!/usr/bin/env sh

notmuch new

# retag all "new" messages "inbox" and "unread"
notmuch tag +inbox +unread -new -- tag:new
# tag all messages from "me" as sent and remove tags inbox and unread
notmuch tag -new -unread +sent -- from:aalbersh@redhat.com or from:andrey.albershteyn@redhat.com

# Newsletters and Misc
notmuch tag +newsletters -inbox -new -- subject:'newsletter*'
notmuch tag +newsletters -inbox -new -- to:'/.*announce@redhat.com/'
notmuch tag +newsletters -inbox -new -- to:announce-list@redhat.com
notmuch tag +newsletters -inbox -new -- to:czech-announce@redhat.com
notmuch tag +newsletters -inbox -new -- from:*@cpucommunications.com
notmuch tag +newsletters -inbox -new -- from:rhl-noreply@redhat.com
notmuch tag +newsletters -inbox -new -- from:ahanakov@redhat.com
notmuch tag +newsletters -inbox -new -- from:academic@redhat.com

# Mailing lists
notmuch tag +fstests -inbox -new -- to:fstests@vger.kernel.org
notmuch tag +linux-xfs -inbox -new -- to:linux-xfs@vger.kernel.org
notmuch tag +linux-fsdevel -inbox -new -- to:linux-fsdevel@vger.kernel.org
notmuch tag +kernel-info -inbox -new -- to:kernel-info@redhat.com
notmuch tag +memos -inbox -new -newsletters -- to:memo-list@redhat.com
notmuch tag +memos -inbox -new -newsletters -- to:brno-memo-list@redhat.com

# Mark all mails which are sent directly to me
# This should be after mailing lists but before services lists. As I want to get
# replies to my inbox from mailing list but don't want to get replies from
# bugzilla or beaker.
notmuch tag +inbox -- to:aalbersh@redhat.com

notmuch tag +bugzilla -inbox -new -- from:bugzilla@redhat.com
notmuch tag +bugzilla -inbox -new -- from:bugzilla-daemon@kernel.org
notmuch tag +bugzilla -inbox -new -- to:bugzilla@redhat.com
notmuch tag +bugzilla -inbox -new -- to:bugzilla-daemon@kernel.org
notmuch tag +bugzilla -inbox -new -- from:jira-issues@redhat.com

notmuch tag +beaker -inbox -new -- subject:'\[Beaker*' or from:beaker@redhat.com or from:*@*rdu2.redhat.com or from:*@*bos.redhat.com
notmuch tag +brew -inbox -new -- from:brew-task-repos@redhat.com
notmuch tag +outage -inbox -unread -new -newsletters -- to:outage-list@redhat.com
notmuch tag +cron -inbox -new -- subject:'Cron*'
notmuch tag +gitlab -inbox -new -- from:*@mg.gitlab.com or from:*@gitlab.com

