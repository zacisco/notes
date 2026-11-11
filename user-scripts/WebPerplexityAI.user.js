// ==UserScript==
// @name          Web Perplexity Fixes
// @description	  Some fixes for Perplexity Web application.
// @version       1.4
// @author        Z@C
// @icon          https://www.perplexity.ai/favicon.svg
// @match         https://www.perplexity.ai/*
// @updateURL     https://raw.githubusercontent.com/zacisco/notes/master/user-scripts/WebPerplexityAI.user.js
// @downloadURL   https://raw.githubusercontent.com/zacisco/notes/master/user-scripts/WebPerplexityAI.user.js
// @run-at        document-end
// ==/UserScript==

(function() {
    'use strict';

// ===== Make WIDE =====
    var css = [
        "/* FOR WIDEE */",
        "main div.isolate div.isolate div.max-w-threadContentWidth {",
//        "    width: 95% !important;",
        "    max-width: 95%;",
        "}",
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
// ===== End WIDE =====

// ===== Remove OVERLAY =====
    function removeOverlay() {
        let block = document.querySelector('div.font-serif.text-3xl.font-normal.text-primary.text-center.block');
        if (block && block.innerText.startsWith('Sign up')) {
            document.querySelector('div.fixed.inset-0.pointer-events-auto').remove();
            document.querySelector('div.fixed.inset-0.flex.items-center.justify-center.pointer-events-none').remove();
        }
    }

    removeOverlay();

    const observer = new MutationObserver(() => {
        removeOverlay();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true
    });
// ===== End OVERLAY =====

})();
