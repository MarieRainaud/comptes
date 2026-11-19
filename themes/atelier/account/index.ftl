<!doctype html>
<html lang="${locale}" dir="${localeDir}">
  <head>
    <#import "theme-resources.ftl" as themeResourceTags>
    <meta charset="utf-8">
    <#if themeResources?? && themeResources.favicons?has_content>
      <@themeResourceTags.renderFavicons themeResources.favicons resourceUrl />
    <#else>
      <link rel="icon" type="${properties.favIconType!'image/svg+xml'}" href="${resourceUrl}${properties.favIcon!'/favicon.svg'}">
    </#if>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light${darkMode?then(' dark', '')}">
    <meta name="description" content="${properties.description!'The Account Console is a web-based interface for managing your account.'}">
    <title>${properties.title!'Account Management'}</title>
    <style>
      body {
        margin: 0;
      }

      body, #app {
        height: 100%;
      }

      .container {
        padding: 0;
        margin: 0;
        width: 100%;
      }

      .keycloak__loading-container {
        height: 100vh;
        width: 100%;
        color: #151515;
        background-color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        margin: 0;
      }

      @media (prefers-color-scheme: dark) {
        .keycloak__loading-container {
          color: #e0e0e0;
          background-color: #1b1d21;
        }
      }

      #loading-text {
        z-index: 1000;
        font-size: 20px;
        font-weight: 600;
        padding-top: 32px;
      }
    </style>
    <script type="importmap">
      {
        "imports": {
          "react": "${resourceCommonUrl}/vendor/react/react.production.min.js",
          "react/jsx-runtime": "${resourceCommonUrl}/vendor/react/react-jsx-runtime.production.min.js",
          "react-dom": "${resourceCommonUrl}/vendor/react-dom/react-dom.production.min.js"
        }
      }
    </script>
    <#if darkMode>
      <script type="module" async blocking="render">
          const DARK_MODE_CLASS = "${properties.kcDarkModeClass}";
          const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

          updateDarkMode(mediaQuery.matches);
          mediaQuery.addEventListener("change", (event) => updateDarkMode(event.matches));

          function updateDarkMode(isEnabled) {
            const { classList } = document.documentElement;

            if (isEnabled) {
              classList.add(DARK_MODE_CLASS);
            } else {
              classList.remove(DARK_MODE_CLASS);
            }
          }
      </script>
    </#if>
    <#if !isSecureContext>
      <script type="module" src="${resourceCommonUrl}/vendor/web-crypto-shim/web-crypto-shim.js"></script>
    </#if>
    <#if devServerUrl?has_content>
      <script type="module">
        import { injectIntoGlobalHook } from "${devServerUrl}/@react-refresh";

        injectIntoGlobalHook(window);
        window.$RefreshReg$ = () => {};
        window.$RefreshSig$ = () => (type) => type;
      </script>
      <script type="module">
        import { inject } from "${devServerUrl}/@vite-plugin-checker-runtime";

        inject({
          overlayConfig: {},
          base: "/",
        });
      </script>
      <script type="module" src="${devServerUrl}/@vite/client"></script>
      <script type="module" src="${devServerUrl}/src/main.tsx"></script>
    </#if>
    <#if entryStyles?has_content>
      <#list entryStyles as style>
        <link rel="stylesheet" href="${resourceUrl}/${style}">
      </#list>
    </#if>
    <#if themeResources?? && themeResources.styles?has_content>
      <@themeResourceTags.renderStyles themeResources.styles resourceUrl />
    <#elseif properties.styles?has_content>
      <#list properties.styles?split(' ') as style>
        <link rel="stylesheet" href="${resourceUrl}/${style}">
      </#list>
    </#if>
    <#if entryScript?has_content>
      <script type="module" src="${resourceUrl}/${entryScript}"></script>
    </#if>
    <#if themeResources?? && themeResources.scripts?has_content>
      <@themeResourceTags.renderScripts themeResources.scripts resourceUrl "module" />
    <#elseif properties.scripts?has_content>
      <#list properties.scripts?split(' ') as script>
        <script src="${resourceUrl}/${script}" type="module"></script>
      </#list>
    </#if>
    <#if entryImports?has_content>
      <#list entryImports as import>
        <link rel="modulepreload" href="${resourceUrl}/${import}">
      </#list>
    </#if>
    <link rel="stylesheet" href="${resourceUrl}/icons/icons.css">
</head>
  <body data-page-id="account">
<script>if (new URLSearchParams(location.search).has("code")) { try { sessionStorage.removeItem("atelier-registration-request"); } catch {} }</script>
    <div id="account-school-profile"></div>
    <div id="app">
      <main class="container">
        <div class="keycloak__loading-container">
          <span class="account-loading-icon image-icon icon-spinner icon-spin" role="progressbar"  aria-label="Chargement du compte"></span>
          <div>
            <p id="loading-text">Chargement du compte</p>
          </div>
        </div>
      </main>
    </div>
    <footer class="site-footer">
      <a class="footer-signature" href="https://portfolio--ninette.ctn.rs/"><img class="footer-logo" src="${resourceUrl}/img/logo-ninette.svg" alt=""  loading="lazy" decoding="async"><span>L’atelier de ninette</span></a>
      <p class="footer-hosting">Hébergé par Simple Containers</p>
      <div class="social-links">
        <a href="https://www.linkedin.com/in/marie-rainaud" target="_blank" rel="noreferrer" aria-label="LinkedIn, nouvel onglet"><span
        class="image-icon icon-linkedin" aria-hidden="true" ></span><span>LinkedIn</span></a>
        <a href="https://github.com/MarieRainaud" target="_blank" rel="noreferrer" aria-label="GitHub, nouvel onglet"><span
        class="image-icon icon-github" aria-hidden="true" ></span><span>GitHub</span></a>
      </div>
    </footer>
    <script type="module" src="${resourceUrl}/school-profile.js"></script>
    <noscript>JavaScript est nécessaire pour gérer le compte.</noscript>
    <script id="environment" type="application/json">
      {
        "serverBaseUrl": "${serverBaseUrl}",
        "authUrl": "${authUrl}",
        "authServerUrl": "${authServerUrl}",
        "realm": "${realm.name}",
        "clientId": "${clientId}",
        "resourceUrl": "${resourceUrl}",
        "logo": "${properties.logo!""}",
        "logoUrl": "${properties.logoUrl!""}",
        "darkMode": ${darkMode?c},
        "baseUrl": "${baseUrl}",
        "locale": "${locale}",
        "referrerName": "${referrerName!""}",
        "referrerUrl": "${referrer_uri!""}",
        "features": {
          "isRegistrationEmailAsUsername": ${realm.registrationEmailAsUsername?c},
          "isEditUserNameAllowed": ${realm.editUsernameAllowed?c},
          "isInternationalizationEnabled": ${realm.isInternationalizationEnabled()?c},
          "isLinkedAccountsEnabled": ${isLinkedAccountsEnabled?c},
          "isMyResourcesEnabled": ${(realm.userManagedAccessAllowed && isAuthorizationEnabled)?c},
          "isViewOrganizationsEnabled": ${isViewOrganizationsEnabled?c},
          "deleteAccountAllowed": ${deleteAccountAllowed?c},
          "updateEmailFeatureEnabled": ${updateEmailFeatureEnabled?c},
          "updateEmailActionEnabled": ${updateEmailActionEnabled?c},
          "isViewApplicationsEnabled": ${isViewApplicationsEnabled?c},
          "isViewGroupsEnabled": ${isViewGroupsEnabled?c},
          "isOid4VciEnabled": ${isOid4VciEnabled?c}
        },
        "scope": "${scope!""}"
      }
    </script>
  </body>
</html>
