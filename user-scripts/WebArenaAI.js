// ==UserScript==
// @name         Web Arena AI (LMArena AI) Fixes
// @description  Some fixes for Arena AI Web application.
// @version      2026-06-24
// @author       Z@C
// @match        https://arena.ai/*
// @icon         https://arena.ai/images/favicon-rebrand.svg
// @updateURL    https://raw.githubusercontent.com/zacisco/notes/master/user-scripts/WebArenaAI.js
// @downloadURL  https://raw.githubusercontent.com/zacisco/notes/master/user-scripts/WebArenaAI.js
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    function debounce(fn, delay) {
        let timer;
        return (...args) => {
            clearTimeout(timer);
            timer = setTimeout(() => fn(...args), delay);
        };
    }

    function safeQuery(root, sel) {
        try {
            return root ? root.querySelector(sel) : document.querySelector(sel);
        } catch (e) {
            return null;
        }
    }

    function safeQueryAll(root, sel) {
        try {
            return root ? root.querySelectorAll(sel) : document.querySelectorAll(sel);
        } catch (e) {
            return [];
        }
    }

    function removeClassPrefix(el, prefix) {
        if (!el || !el.classList) return;
        const toRemove = [];
        for (const c of el.classList) {
            if (c.startsWith(prefix)) toRemove.push(c);
        }
        toRemove.forEach(c => el.classList.remove(c));
    }

    const OL_BLOCK = "ol[class*='max-w-screen-']";
    const FULL_POPUP_RESPONSE_BLOCK = "div#chat-area div[class~='bg-surface-primary'][class~='h-full']";
    const POPUP_MSG_BLOCK = "div[class*='md:max-w-']";
    const MSG_BLOCK = "div[class*='max-w-']";
    const CODE_BLOCK = "div[data-code-block='true']";
    const USR_MSG = "div[class~='max-w-prose']";

    const DB_NAME = "lmarena-archive-db";
    const DB_VERSION = 1;
    const STORE = "messages";

    function openDB() {
        return new Promise((resolve, reject) => {
            const req = indexedDB.open(DB_NAME, DB_VERSION);

            req.onupgradeneeded = () => {
                const db = req.result;
                if (!db.objectStoreNames.contains(STORE)) {
                    const store = db.createObjectStore(STORE, { keyPath: "id", autoIncrement: true });
                    store.createIndex("timestamp", "timestamp", { unique: false });
                    store.createIndex("role", "role", { unique: false });
                }
            };

            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
        });
    }

    function idbPut(db, value) {
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE, "readwrite");
            const store = tx.objectStore(STORE);
            const req = store.add(value);
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
        });
    }

    function idbGetAll(db) {
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE, "readonly");
            const store = tx.objectStore(STORE);
            const req = store.getAll();
            req.onsuccess = () => resolve(req.result || []);
            req.onerror = () => reject(req.error);
        });
    }

    function idbClear(db) {
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE, "readwrite");
            const store = tx.objectStore(STORE);
            const req = store.clear();
            req.onsuccess = () => resolve();
            req.onerror = () => reject(req.error);
        });
    }

    function idbDeleteOldest(db, count) {
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE, "readwrite");
            const store = tx.objectStore(STORE);
            const index = store.index("timestamp");
            const req = index.openCursor();
            let removed = 0;

            req.onsuccess = () => {
                const cursor = req.result;
                if (!cursor || removed >= count) {
                    resolve(removed);
                    return;
                }
                cursor.delete();
                removed++;
                cursor.continue();
            };

            req.onerror = () => reject(req.error);
        });
    }

    function makeWide() {
        let ol = safeQuery(document, OL_BLOCK);
        if (!ol) {
            ol = safeQuery(document, "ol");
        }
        if (!ol) return;
        console.debug("make wide");
        removeClassPrefix(ol, "max-w-screen-");
        ol.style.cssText = "width: 95%;";

        let msg_blks = safeQueryAll(ol, `:scope > ${MSG_BLOCK}`);
        let code_blks = safeQueryAll(ol, `:scope ${CODE_BLOCK}`);
        let user_msg_blks = safeQueryAll(ol, `:scope > ${MSG_BLOCK} > ${MSG_BLOCK}`);
        let user_msg = safeQueryAll(ol, `:scope > ${MSG_BLOCK} > ${MSG_BLOCK} > div > div > ${USR_MSG}`);
        let see_other_blks = safeQueryAll(ol, `:scope > div[class='w-full'] > ${MSG_BLOCK}`);
        let other_blks = safeQueryAll(ol, `:scope > div[class='w-full'] > div ${MSG_BLOCK}`);

        msg_blks.forEach(el => removeClassPrefix(el, "max-w-"));

        code_blks.forEach(el => {
            el.classList.remove("w-full");
            el.style.cssText = "width: -moz-fit-content; width: fit-content;";
        });

        user_msg_blks.forEach(el => {
            removeClassPrefix(el, "max-w-");
            el.style.cssText = "width: -moz-fit-content; width: fit-content; max-width: 75%;";
        });

        user_msg.forEach(el => el.classList.remove("max-w-prose"));

        see_other_blks.forEach(el => removeClassPrefix(el, "max-w-"));
        other_blks.forEach(el => removeClassPrefix(el, "max-w-"));

        const rootEl = safeQuery(document, FULL_POPUP_RESPONSE_BLOCK);
        if (rootEl) {
            let full_popup_response_blk = safeQuery(rootEl, POPUP_MSG_BLOCK) || safeQuery(rootEl, "div");
            if (full_popup_response_blk) {
                removeClassPrefix(full_popup_response_blk, "md:max-w-");
                full_popup_response_blk.style.cssText = "width: 95%;";
                const popupCodeBlocks = safeQueryAll(full_popup_response_blk, CODE_BLOCK);
                popupCodeBlocks.forEach(el => {
                    el.classList.remove("w-full");
                    el.style.cssText = "width: -moz-fit-content; width: fit-content;";
                });
            }
        }
    }

    makeWide();

    const onDomStable = debounce(makeWide, 2500);
    const chatArea = safeQuery(document, "div#chat-area") || document.body;

    const observer = new MutationObserver(onDomStable);
    observer.observe(chatArea, {
        childList: true,
        subtree: true,
        attributes: false,
        characterData: false
    });

    const N = 30;
    const M = 10;

    let dbPromise = openDB();

    async function tryCompressDOM() {
        console.debug("try compress");
        const db = await dbPromise;
        const container = safeQuery(document, "div#chat-area ol");
        const blocks = safeQueryAll(document, "div#chat-area ol > div");
        if (!container || blocks.length <= N + M) return;

        const oldBlocks = [...blocks].slice(-(blocks.length - N));
        if (!oldBlocks.length) return;

        console.debug("compress: " + oldBlocks.length);
        const batch = oldBlocks.map(el => {
            const role = el.classList.contains("flex") && el.classList.contains("justify-end") ? "user" : "assistant";
            return {
                role,
                html: el.outerHTML,
                timestamp: Date.now()
            };
        });

        for (const item of batch) {
            await idbPut(db, item);
        }

        oldBlocks.forEach(el => el.remove());
    }

    tryCompressDOM();

    const observeNewMessages = debounce(() => {
        tryCompressDOM().catch(err => console.warn("IDB archive error", err));
    }, 10000);

    const archTarget = safeQuery(document, "div#chat-area ol") || document.body;
    const mo = new MutationObserver(observeNewMessages);
    mo.observe(archTarget, {
        childList: true,
        subtree: true,
        attributes: false,
        characterData: false
    });

    async function saveSessionToMarkdownFile() {
        const db = await dbPromise;
        const items = await idbGetAll(db);
        const all = items.sort((a, b) => a.timestamp - b.timestamp);

        let md = "# LMArena Archive (Session)\n\n";
        for (const msg of all) {
            const role = msg.role === "user" ? "👤" : "🤖";
            const ts = new Date(msg.timestamp).toLocaleString();
            const roleLabel = msg.role === "user" ? "user" : "assistant";
            md += `## ${role} (${roleLabel}) — ${ts}\n\n`;
            md += "```html\n";
            md += (msg.html || "") + "\n";
            md += "```\n\n";
        }

        const blob = new Blob([md], { type: "text/markdown; charset=utf-8" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `lmarena_session_${Date.now()}.md`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);

        await idbClear(db);
    }

    async function renderMarkdownFile(file) {
        const text = await file.text();
        const container = document.createElement("div");
        container.style.cssText = `
            position: fixed; top: 60px; left: 10px; right: 10px;
            background: #1e1e1e; color: #e0e0e0; padding: 10px; border-radius: 5px;
            max-height: 60vh; overflow-y: auto; z-index: 9998; font-size: 14px;
        `;

        const lines = text.split("\n");
        let msgDiv = null;
        let inCodeBlock = false;

        for (const line of lines) {
            if (line.trim() === "```html") {
                inCodeBlock = true;
                if (!msgDiv) {
                    msgDiv = document.createElement("div");
                    msgDiv.style.marginBottom = "15px";
                }
                continue;
            }
            if (line.trim() === "```" && inCodeBlock) {
                inCodeBlock = false;
                continue;
            }
            if (line.startsWith("## ")) {
                if (msgDiv) container.appendChild(msgDiv);
                msgDiv = document.createElement("div");
                msgDiv.style.marginBottom = "10px";
                msgDiv.textContent = line;
            } else if (inCodeBlock && msgDiv) {
                const pre = document.createElement("pre");
                const code = document.createElement("code");
                code.textContent = line;
                pre.appendChild(code);
                msgDiv.appendChild(pre);
            }
        }

        if (msgDiv) container.appendChild(msgDiv);
        document.body.appendChild(container);

        const closeBtn = document.createElement("button");
        closeBtn.textContent = "X Close";
        closeBtn.style.cssText = "position: fixed; top: 60px; right: 10px; padding: 4px; z-index: 9999;";
        closeBtn.onclick = () => {
            document.body.removeChild(container);
            document.body.removeChild(closeBtn);
        };
        document.body.appendChild(closeBtn);
    }

    const addSaveArchiveButton = () => {
        const btn = document.createElement("button");
        btn.textContent = "💾 Save session (Markdown)";
        btn.style.cssText = "position: fixed; top: 10px; right: 50%; z-index: 9999; padding: 8px;";
        btn.onclick = () => saveSessionToMarkdownFile().catch(err => console.warn(err));
        document.body.appendChild(btn);
    };

    const addLoadArchiveButton = () => {
        const btn = document.createElement("button");
        btn.textContent = "📥 Load archive (Markdown)";
        btn.style.cssText = "position: fixed; top: 10px; right: 35%; z-index: 9999; padding: 8px;";

        const fileInput = document.createElement("input");
        fileInput.type = "file";
        fileInput.accept = ".md,.txt";
        fileInput.style.display = "none";
        document.body.appendChild(fileInput);

        fileInput.onchange = async () => {
            if (!fileInput.files.length) return;
            await renderMarkdownFile(fileInput.files[0]);
        };

        btn.onclick = () => fileInput.click();
        document.body.appendChild(btn);
    };

    addSaveArchiveButton();
    addLoadArchiveButton();
})();
