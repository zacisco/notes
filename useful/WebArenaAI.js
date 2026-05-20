// ==UserScript==
// @name         Web Arena AI (LMArena AI) Fixes
// @description  Some fixes for Arena AI Web application.
// @version      2026-05-20
// @author       Z@C
// @match        https://arena.ai/*
// @icon         https://arena.ai/images/favicon-rebrand.svg
// @updateURL    https://raw.githubusercontent.com/zacisco/notes/master/useful/WebArenaAI.js
// @downloadURL  https://raw.githubusercontent.com/zacisco/notes/master/useful/WebArenaAI.js
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

// ===== Make WIDE =====
    const divs = document.querySelectorAll("ol[class*=max-w-screen-] > div[class*=max-w-]");
    divs.forEach(el => [...el.classList]
                 .filter(c => c.includes("max-w-"))
                 .forEach(c => el.classList.remove(c))
                );

    const ol = document.querySelector("ol[class*=max-w-screen-]");
    [...ol.classList].filter(c => c.includes("max-w-screen-")).forEach(c => ol.classList.remove(c));
    ol.style.cssText="width: 95%";
// ===== End WIDE =====

})();
