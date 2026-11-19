document.querySelector('#register').addEventListener('click', () => {
  try { sessionStorage.setItem('atelier-registration-request', String(Date.now())); } catch { }
});
document.querySelector('#login').addEventListener('click', () => {
  try { sessionStorage.removeItem('atelier-registration-request'); } catch { }
});
