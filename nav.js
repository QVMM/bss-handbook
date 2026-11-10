// 仅用于：小屏菜单开关、打印时展开所有“参考答案”。
(function(){
  var b=document.querySelector('.topbar button');
  if(b){b.addEventListener('click',function(){document.body.classList.toggle('nav-open');});}
  document.addEventListener('click',function(e){
    if(document.body.classList.contains('nav-open') && !e.target.closest('.sidebar') && !e.target.closest('.topbar')){document.body.classList.remove('nav-open');}
  });
  window.addEventListener('beforeprint',function(){document.querySelectorAll('details').forEach(function(d){d.setAttribute('open','');});});
  var s=document.querySelector('.sidebar'),a=document.querySelector('.sidebar a.active'); if(s&&a){s.scrollTop=Math.max(0,a.offsetTop-s.clientHeight/2);}
})();
