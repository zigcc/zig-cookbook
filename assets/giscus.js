function appendGiscusScript() {
  const pageDiv = document.querySelector('div.content > article');

  if (!pageDiv) {
    console.error('Could not find div with class "page"');
    return;
  }
  // 创建评论容器
  const commentsDiv = document.createElement('div');
  commentsDiv.className = 'giscus';
  pageDiv.appendChild(commentsDiv);

  // 创建 script 元素
  const script = document.createElement('script');
    // 设置脚本属性
  script.src = "https://giscus.app/client.js";
  script.setAttribute("data-repo", "zigcc/zig-cookbook");
  script.setAttribute("data-repo-id", "R_kgDOK34kdA");
  script.setAttribute("data-category", "General");
  script.setAttribute("data-category-id", "DIC_kwDOK34kdM4Clt_g");
  script.setAttribute("data-mapping", "pathname");
  script.setAttribute("data-strict", "1");
  script.setAttribute("data-reactions-enabled", "1");
  script.setAttribute("data-emit-metadata", "0");
  script.setAttribute("data-input-position", "bottom");
  script.setAttribute("data-theme", "preferred_color_scheme");
  script.setAttribute("data-lang", "en");
  script.setAttribute("crossorigin", "anonymous");
  script.async = true;

  // 将脚本追加到 body 末尾
  pageDiv.appendChild(script);
}

document.addEventListener('DOMContentLoaded', appendGiscusScript);
