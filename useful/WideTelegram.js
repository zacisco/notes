// ==UserScript==
// @name          Web Telegram Wide
// @description	  Wide style for Telegram Web application.
// @author        Z@C
// @icon          https://web.telegram.org/a/favicon.ico
// @match         https://web.telegram.org/*
// @run-at        document-end
// @version       0.5
// ==/UserScript==
(function() {var css = [
	"/* FOR WIDEE */",
	".bubbles-inner {",
    "    width: 95%;",
    "    max-width: unset !important;",
    "}",
    ".MessageList .messages-container {",
	"    width: 95% !important;",
	"    max-width: unset !important;",
	"}",
    // ".Message .message-select-control .icon.icon-select {",
    // "    left: unset !important;",
    // "    top: unset !important;",
    // "}",
	".Message > .message-content-wrapper {",
	"    max-width: 85%;",
	"    float: right;",
	"}",
    ".Message .has-reactions {",
    "    max-width: unset !important;",
    "}",
	".message-content:not(.document):not(.media):not(.web-page) {",
	"    max-width: 100%;",
	"}",
	// ".bubble-content .message {",
	// "    max-width: unset !important;",
	// "}",
	// ".bubble .service .is-date {",
	// "    width: 95%;",
	// "    max-width: unset !important;",
	// "}",
	"#Main:not(.right-column-open) #MiddleColumn .middle-column-footer {",
	"    width: 95% !important;",
	"    max-width: unset !important;",
	"}",
    "#Main.right-column-open #MiddleColumn .middle-column-footer {",
	"    max-width: calc(100% - var(--right-column-width));",
	"}",
	// ".chat-input,",
	// "#MiddleColumn .middle-column-footer {",
	// "    width: 95% !important;",
	// "    max-width: unset !important;",
	// "}",
	// ".chat-input .chat-input-container {",
	// "    max-width: unset;",
	// "}",
	// "#MiddleColumn .Composer.hover-disabled {",
	// "    visibility: hidden;",
	// "}",
	// ".select-mode-active+.middle-column-footer .Composer {",
	// "    position: unset !important;",
	// "}",
	"/* FOR WIDEE END */"
].join("\n");
if (typeof GM_addStyle != "undefined") {
	GM_addStyle(css);
} else if (typeof PRO_addStyle != "undefined") {
	PRO_addStyle(css);
} else if (typeof addStyle != "undefined") {
	addStyle(css);
} else {
	var node = document.createElement("style");
	node.type = "text/css";
	node.appendChild(document.createTextNode(css));
	var heads = document.getElementsByTagName("head");
	if (heads.length > 0) {
		heads[0].appendChild(node);
	} else {
		// no head yet, stick it whereever
		document.documentElement.appendChild(node);
	}
}
})();
