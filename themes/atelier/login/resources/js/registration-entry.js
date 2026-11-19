// Utilise le lien d’inscription fourni par la page de connexion.
document.addEventListener('DOMContentLoaded', () => {
  try {
    const requested = Number(sessionStorage.getItem('atelier-registration-request'));
    sessionStorage.removeItem('atelier-registration-request');
    if (document.body.dataset.pageId !== 'login-login' || !requested || Date.now() - requested > 60000) return;
    const link = document.querySelector('#kc-registration a');
    if (link) location.replace(link.href);
  } catch { /* Le lien d’inscription reste disponible si le stockage du navigateur est désactivé. */ }
});
