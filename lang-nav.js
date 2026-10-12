/* v8i8 說明頁：頁尾語言連結文字（跟首頁 vd_lang 同步；小羅 2026-10-12） */
(function () {
  var D = {
    home:       {'zh-TW': '回首頁',   'zh-CN': '回首页',   'en': 'Home'},
    about:      {'zh-TW': '關於我們', 'zh-CN': '关于我们', 'en': 'About Us'},
    guide:      {'zh-TW': '使用說明', 'zh-CN': '使用说明', 'en': 'How to Use'},
    privacy:    {'zh-TW': '隱私權政策', 'zh-CN': '隐私权政策', 'en': 'Privacy Policy'},
    disclaimer: {'zh-TW': '免責聲明', 'zh-CN': '免责声明', 'en': 'Disclaimer'},
    contact:    {'zh-TW': '聯絡我們', 'zh-CN': '联系我们', 'en': 'Contact Us'}
  };
  function lang() {
    var l = document.documentElement.lang || 'zh-TW';
    return D.home[l] ? l : 'zh-TW';
  }
  function fill() {
    var l = lang();
    document.querySelectorAll('footer .nav a').forEach(function (a) {
      var k = a.getAttribute('data-t');
      if (k && D[k]) a.textContent = D[k][l];
    });
  }
  fill();
  new MutationObserver(fill).observe(document.documentElement, { attributes: true, attributeFilter: ['lang'] });
})();
