# Allow use of Inline-html using the <<inlinehtml>> wikit markup, boolean.
set ::WikitWub::inline_html 0

# Allow inclusion of other pages using the <<include: >> wikit markup, boolean.
set ::WikitWub::include_pages 0

# Run the wiki in read-only mode, message to display why wiki is read-only. If empty string, wiki is writable.
set ::WikitWub::readonly ""

# Hide read-only message but still make the wiki read-only, boolean.
set ::WikitWub::hidereadonly 0

# Set text to be used when editing a page for the first time, string.
set ::WikitWub::empty_template "This is an empty page.\n\nEnter page contents here, upload content using the button above, or click cancel to leave it empty.\n\n<<categories>>Enter Category Here\n"

# Title of the wiki, string.
set ::WikitWub::wiki_title ""

# URL used inheader, string
set ::WikitWub::text_url "www.mywiki.net"

# Use page 0 as welcome page, boolean.
set ::WikitWub::welcomezero 0

# Permissions
set perms {admin {admin admin}}

# ReCAPTCHA keys, use to protect 'new page' and 'revert'. Get your keys at www.recaptcha.com.
set ::WikitWub::need_recaptcha 0
set ::WikitWub::recaptcha_public ""
set ::WikitWub::recaptcha_private ""


# Google search and set google search API key to enable searching using google. Requires google bot to have access to you site.
set ::WikitWub::gsearch 0
set ::google_jsapi_key ""
