// ==UserScript==
// @name         Web Arena AI (LMArena AI) Fixes
// @description  Some fixes for Arena AI Web application.
// @version      2026-05-21
// @author       Z@C
// @match        https://arena.ai/*
// @icon         https://arena.ai/images/favicon-rebrand.svg
// @updateURL    https://raw.githubusercontent.com/zacisco/notes/master/useful/WebArenaAI.js
// @downloadURL  https://raw.githubusercontent.com/zacisco/notes/master/useful/WebArenaAI.js
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    const OL_BLOCK="ol[class*='max-w-screen-']";
    const FULL_POPUP_RESPONSE_BLOCK="div#chat-area div[class~='bg-surface-primary'][class~='h-full']";
    const POPUP_MSG_BLOCK="div[class*='md:max-w-']";
    const MSG_BLOCK="div[class*='max-w-']";
    const CODE_BLOCK="div[data-code-block='true']";
    const USR_MSG="div[class~='max-w-prose']";

// ===== Make WIDE =====
    function removeClass(el, className) {
        [...el.classList].filter(c => c.includes(className)).forEach(c => el.classList.remove(c));
    }

    function makeWide() {
        let msg_blks, code_blks, user_msg_blks, user_msg, see_other_blks, other_blks;
        let full_popup_response_blk;
        let firstCall = true;

        let ol = document.querySelector(OL_BLOCK);
        if (!ol) {
            firstCall = false;
        }

        if (firstCall) {
            msg_blks = document.querySelectorAll(`${OL_BLOCK} > ${MSG_BLOCK}`);
            code_blks = document.querySelectorAll(`${OL_BLOCK} > div ${CODE_BLOCK}`);
            user_msg_blks = document.querySelectorAll(`${OL_BLOCK} > ${MSG_BLOCK} > ${MSG_BLOCK}`);
            user_msg = document.querySelectorAll(`${OL_BLOCK} > ${MSG_BLOCK} > ${MSG_BLOCK} > div > div > ${USR_MSG}`);
            see_other_blks = document.querySelectorAll(`${OL_BLOCK} > div[class='w-full'] > ${MSG_BLOCK}`);
            other_blks = document.querySelectorAll(`${OL_BLOCK} > div[class='w-full'] > div ${MSG_BLOCK}`);
        } else {
            ol = document.querySelector("ol");
            msg_blks = document.querySelectorAll(`ol > ${MSG_BLOCK}`);
            user_msg_blks = document.querySelectorAll(`ol > div:not(.w-full) > ${MSG_BLOCK}`);
            code_blks = document.querySelectorAll(`ol > div ${CODE_BLOCK}`);
            user_msg = document.querySelectorAll(`ol > div > div > div > div > ${USR_MSG}`);
            see_other_blks = document.querySelectorAll(`ol > div[class='w-full'] > ${MSG_BLOCK}`);
            other_blks = document.querySelectorAll(`ol > div[class='w-full'] > div ${MSG_BLOCK}`);
        }

        if (ol) {
            removeClass(ol, "max-w-screen-");
            ol.style.cssText="width: 95%;";

            msg_blks.forEach(el => removeClass(el, "max-w-"));

            code_blks.forEach(el => {
                el.classList.remove("w-full");
                el.style.cssText="width: -moz-fit-content; width: fit-content;";
            });

            user_msg_blks.forEach(el => {
                removeClass(el, "max-w-");
                el.style.cssText="width: -moz-fit-content; width: fit-content; max-width: 75%;";
            });

            user_msg.forEach(el => el.classList.remove("max-w-prose"));

            see_other_blks.forEach(el => removeClass(el, "max-w-"));

            other_blks.forEach(el => removeClass(el, "max-w-"));

        }

        let rootEl = document.querySelector(FULL_POPUP_RESPONSE_BLOCK);
        if (rootEl) {
            full_popup_response_blk = document.querySelector(`${FULL_POPUP_RESPONSE_BLOCK} > ${POPUP_MSG_BLOCK}`);
            if (full_popup_response_blk) {
                code_blks = document.querySelectorAll(`${FULL_POPUP_RESPONSE_BLOCK} > ${POPUP_MSG_BLOCK} ${CODE_BLOCK}`);
            } else {
                full_popup_response_blk = document.querySelector(`${FULL_POPUP_RESPONSE_BLOCK} > div`);
                code_blks = document.querySelectorAll(`${FULL_POPUP_RESPONSE_BLOCK} > div ${CODE_BLOCK}`);
            }
            removeClass(full_popup_response_blk, "md:max-w-");
            full_popup_response_blk.style.cssText="width: 95%;";
            code_blks.forEach(el => {
                el.classList.remove("w-full");
                el.style.cssText="width: -moz-fit-content; width: fit-content;";
            });
        }

        //let block = document.querySelector('div.text-foreground.block');
        //if (block && block.innerText.startsWith('Sign up')) {
        //    block.closest('div[data-type="portal"] > div').remove();
        //}
    }

    makeWide();

    const observer = new MutationObserver(() => {
        makeWide();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true
    });
// ===== End WIDE =====

})();
