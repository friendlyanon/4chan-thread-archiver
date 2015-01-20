#!/bin/bash

name=$(basename $0)

usage () {
	echo "$name - 4chan thread downloader"
	echo ""
	echo "Usage: $name [4chan thread URL] <time value and/or return target>"
	echo ""
	echo "  <time value>"
	echo "     1: run script once"
	echo "     10 - 999: Set the initial"
	echo "      waiting time between runs"
	echo "     Default: 10 seconds"
	echo ""
	echo "  <return target>"
	echo "     Set the target path of the 'Return'"
	echo "      link"
	echo "     Default: ./"
	exit 0
}

[ $# -eq 0 ] && usage

for arg in $@; do
	urltest=$(echo "$arg" | sed -e "s_^https_http_" | egrep -o "^http://boards.4chan.org/[a-z0-9]+/thread/[0-9]+")
	timetest=$(echo "$arg" |egrep "^[0-9]{1,3}$")
	if [ $urltest ]; then
		URL="$urltest"
	elif [ $timetest ]; then
		SLP="$arg"
	else
		RET="$arg"
	fi
done

[ ! $URL ] && usage

echo "4chan downloader"

LOC=$(echo "$URL" | sed 's_.*/\([^/]\+\)/thread/\([0-9]\+\)_\1\_\2_')

if [ ! $LOC ]; then
	echo "Can't determine the thread's number"
	echo "Use valid URL without hash or search tags"
	echo ""
	usage
fi

ST="s.4cdn.org"
[ ! $SLP ] && SLP="10"
[ ! $RET ] && RET="./"
SLAP=$SLP
NO=$(echo "$LOC" | grep -o '[0-9]\+$')
BO=$(echo "$LOC" | grep -o '^[^_]\+')
LM=""
alias wget="wget --referer=\"http://boards.4chan.org/"$BO"\""

thejob () {
	if [ ! -d $LOC ]; then
		mkdir $LOC
	fi

	if [ ! -d $LOC/misc ]; then
		mkdir $LOC/misc
	fi

	cd $LOC/misc

	touch images_list

	egrep "File: <a[^>]*>[^<]*</a>[^<]*<span[^>]*>[^<]*" ../../$LOC.html -o | sed -e 's_^.*>\([0-9]\+\....\)</a>-(\([^)]\+\), <span>\?\(.*\)$_\1|\2|\3_g' -e 's/ title="\([^"]*\).*$/\1/g' -e '/^$/d' -e '$ s_$_\n_' > a

	cat images_list a | sed -e '$ s@$@\n'$(ls|grep spoiler)'@' | sort | uniq | sed -e '/^$/d' > images_list

	rm a

	if [ ! -s gallery.html ]; then
		cat <<EOF > gallery.html
<!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="viewport" content="width=device-width, user-scalable=yes, initial-scale=1.0" /><title>Image gallery</title><style type="text/css">/*<![CDATA[*/.loading{display:inline-block;width:0;height:0;border-right:20px solid #39f;border-top:20px solid red;border-left:20px solid yellow;border-bottom:20px solid green;border-radius:20px;-moz-border-radius:20px;-webkit-border-radius:20px;animation:bganim 1.5s ease 0s infinite;-moz-animation:bganim 1.5s ease 0s infinite;-webkit-animation:bganim 1.5s ease 0s infinite}@keyframes bganim{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}@-moz-keyframes bganim{from{-moz-transform:rotate(0deg)}to{-moz-transform:rotate(360deg)}}@-webkit-keyframes bganim{from{-webkit-transform:rotate(0deg)}to{-webkit-transform:rotate(360deg)}}html,body{width:100%;height:100%;margin:0;font-family:Helvetica,Arial,Verdana,sans-serif;text-align:center}div:not(.loading){text-align:center;max-width:250px;padding:5px;border:1px solid black;clear:both;display:inline-block;margin-top:5px}img{max-width:250px;max-height:250px}s{margin-top:3px;display:block;word-wrap:break-word;text-decoration:none}table{border:0;width:100%;height:100%}td{width:50%;text-align:left}td:first-of-type{text-align:right}.middle{vertical-align:middle}/*]]>*/</style></head><body><table><tr><td><div class="loading"></div></td><td class="middle">Loading...</td></tr></table><script type="text/javascript">/*<![CDATA[*/var d=document,\$=function(a){return d.querySelector(a)},html="<h1>Image gallery</h1>",x=new XMLHttpRequest(),td=\$(".middle"),r;x.onreadystatechange=function(){if(x.readyState==4){if(x.status==200){td.innerHTML="Parsing gallery...";var b = x.responseText.split("\n");b.some(function(a){if(b.lastIndexOf(a)==0&&a.indexOf('|')==-1)return;a=a.split("|");if(a.length>1){html+='<div><a href="../'+a[0]+'"><img src="'+a[1].indexOf('Spoiler')==0?b[b.length-1]:(a[0].split(".")[0]+"s.jpg")+'" alt="Image" /></a><s>'+a[1]+'</s><s>'+a[2]+'</s></div>'}return});\$("body").innerHTML=html}else{\$("td").innerHTML="Er<br>Are you trying to";td.innerHTML="ror<br>open this offline?"}}};x.open("GET","images_list",true);x.setRequestHeader("Cache-Control","no-cache");td.innerHTML="Fetching images list...";x.send(null)//]]></script></body></html>
EOF
	fi

	cd ../..

	egrep "//.\.t\.4cdn\.org/[^.]+\.jpg" $LOC.html -o | sed 's_^//_http:&_g' > $LOC/misc/misc

	egrep "//${ST}/image/[^.]+\...." $LOC.html -o | sed 's_^//_http:&_g' | uniq >> $LOC/misc/misc

	egrep "//${ST}/image/country/[^.]+\...." $LOC.html -o | sed 's_^//_http:&_g' >> $LOC/misc/misc

	egrep "//${ST}/css/[a-z]+\.[0-9]+\.css" $LOC.html -o | sed -e 's_^//_http:&_' | head -n1 > $LOC/misc/css

	egrep "//${ST}/css/[a-z]+\.[0-9]+\.css" $LOC.html -o | sed -e 's_^//_http:&_' | egrep 'tomorrow|prettify' >> $LOC/misc/css

	egrep 'data-src="[^.]+\.[^"]+' $LOC.html -o | sed 's_^data.src."_http://'$ST'/image/title/_' | head -n1 > $LOC/misc/logo

	egrep "//i\.4cdn\.org/[^.]+\.(jpg|png|gif|webm)" $LOC.html -o | sed 's_^//_http:&_g' > $LOC/images

	sed -i -e 's@\(</head>\)@\n\1@' $LOC.html

	mv $LOC.html a

	head -n1 a > $LOC.html

	cat << EOF >> $LOC.html
<!<script>/*<![CDATA[*/var d=document,dE=d.documentElement,lS=localStorage,z,i,u="threaddl_arch_theme",e;Element.prototype.gA=function(a){return this.getAttribute(a);};Element.prototype.pN=function(){return this.parentNode;};String.prototype.iO=function(a){return this.indexOf(a);};function s(a,b,c){a.setAttribute(b,c);}function sT(b){lS.setItem(u,b);for(i=0;(z=d.getElementsByTagName("link")[i]);i++){if(z.gA("rel").iO("style")!=1&&z.gA("title")){z.disabled=true;if(z.gA("title")==(b?"switch":"Tomorrow"))z.disabled=false;}}}sT(parseInt(lS.getItem(u))||0);(function(){var a,b,c,e,f,g,h,i,j,k,l=parseInt(lS.qp_opt),m,n=parseInt(lS.img_hover),o;String.prototype.reverse=function(){return this.split("").reverse().join("")};k={hover:function(a){var b,c,d,e,f,g,h;d=a.clientX,e=a.clientY;g=k.el.style;b=dE.clientHeight,c=dE.clientWidth;f=k.el.offsetHeight;h=e-120;g.top=b<=f||h<=0?"0px":h+f>=b?b-f+"px":h+"px";if(d<=c-400){g.left=d+45+"px";return g.right=null}else{g.left=null;return g.right=c-d+45+"px"}},hoverend:function(){a.rm(k.el);return delete k.el}};a=function(a,b){if(b==null){b=d.body}return b.querySelector(a)};a.extend=function(a,b){var c;for(c in b){a[c]=b[c]}};a.extend(a,{id:function(a){return d.getElementById(a)},addStyle:function(b){var c;c=a.el("style",{textContent:b});a.add(d.head,c);return c},x:function(a,b){b===null&&(b=d.body);return d.evaluate(a,b,null,8,null).singleNodeValue},addClass:function(a,b){return a.classList.add(b)},rmClass:function(a,b){return a.classList.remove(b)},rm:function(a){return a.pN().removeChild(a)},tn:function(a){return d.createTextNode(a)},nodes:function(a){var b,c,e=0;if(!(a instanceof Array)){return a}b=d.createDocumentFragment();for(;e<a.length;e++){c=a[e];b.appendChild(c)}return b},add:function(b,c){return b.appendChild(a.nodes(c))},after:function(b,c){return b.pN().insertBefore(a.nodes(c),b.nextSibling)},el:function(b,c){var e=d.createElement(b);if(c){a.extend(e,c)}return e},on:function(a,b,c){var d,e=0,f=b.split(" ");for(;e<f.length;e++){d=f[e];a.addEventListener(d,c,false)}},off:function(a,b,c){var d,e=0,f=b.split(" ");for(;e<f.length;e++){d=f[e];a.removeEventListener(d,c,false)}},visible:function(a){var b = a.getBoundingClientRect();return (b.top+b.height>=0&&(dE.clientHeight-b.bottom)+b.height>=0)}});b=function(a,b){if(b==null){b=d.body}return [].slice.call(b.querySelectorAll(a))};c={post:function(b,d){var e=a.id("pc"+b);e&&a.add(d,c.cleanPost(e.cloneNode(true)))},cleanPost:function(c){var d,e,f,g,h,i=Date.now(),j=a(".post",c),k=_j=_k=_l=0,l=[].slice.call(c.childNodes),m=b(".inline",j),n=b(".inlined",j);for(;k<l.length;k++){if((d=l[k])!==j){a.rm(d)}}for(;_j<m.length;_j++){a.rm(m[_j])}for(;_k<n.length;_k++){a.rmClass(n[_k],"inlined")}(f=b("[id]",c)).push(c);for(;_l<f.length;_l++){(e=f[_l]).id=""+i+"_"+e.id}a.rmClass(c,"forwarded");a.rmClass(c,"qphl");a.rmClass(j,"highlight");a.rmClass(j,"qphl");return c}};j={init:function(){return e.callbacks.push(this.node)},node:function(b){var c=a(".postInfo > .dateTime",b.el);if(b.isInlined){return}j.date=new Date(c.dataset.utc*1e3);c.title="4chan time: "+c.textContent;return c.textContent=j.zeroPad(j.date.getMonth()+1)+"/"+j.zeroPad(j.date.getDate())+"/"+(j.date.getFullYear()-2e3)+"("+j.day[j.date.getDay()]+")"+j.zeroPad(j.date.getHours())+":"+j.zeroPad(j.date.getMinutes())},day:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],zeroPad:function(a){if(10>a){return"0"+a}else{return a}}};g={init:function(){return e.callbacks.push(this.node)},node:function(b){var c,d,e,f,g,j,k={},n=0,m=b.quotes;if(b.isInlined){return}for(;m.length>n;n++){j=m[n];if(g=j.hash.slice(2)){k[g]=true}}c=a.el("a",{href:"#p"+b.ID,className:"backlink",textContent:">>"+b.ID});for(g in k){if(!(e=a.id("pi"+g))||/\bop\b/.test(e.pN().className)){continue}f=c.cloneNode(true);l&&a.on(f,"mouseover",i.mouseover);a.on(f,"click",h.toggle);if(!(d=a.id("blc"+g))){d=a.el("span",{className:"container",id:"blc"+g});a.add(e,d)}a.add(d,[a.tn(" "),f])}}};h={init:function(){return e.callbacks.push(this.node)},node:function(b){var c,d=_j=0,e=b.quotes,f=b.backlinks;for(;e.length>d;d++){c=e[d];if(!c.hash){continue}c.removeAttribute("onclick");a.on(c,"click",h.toggle)}for(;f.length>_j;_j++){a.on(f[_j],"click",h.toggle)}},toggle:function(b){if(b.shiftKey||b.altKey||b.ctrlKey||b.metaKey||b.button!==0){return}b.preventDefault();var c=this.dataset.id||this.hash.slice(2);if(/\binlined\b/.test(this.className)){h.rm(this,c)}else{if(a.x("ancestor::div[contains(@id,'p"+c+"')]",this)){return}h.add(this,c)}return this.classList.toggle("inlined")},add:function(b,d){var e=d,f=a.id("p"+e),g=a.el("div",{id:"i"+e,className:"inline"}),h=/\bbacklink\b/.test(b.className),i=h?b.pN():a.x("ancestor-or-self::*[parent::blockquote][1]",b);a.after(i,g);c.post(e,g);if(!f){return}if(h){a.addClass(f.pN(),"forwarded");++f.dataset.forwarded||(f.dataset.forwarded=1)}},rm:function(c,d){var e,f,g,h,i;e=a.x("following::div[@id='i"+d+"']",c);a.rm(e);i=b(".backlink.inlined",e);for(g=0,h=i.length;h>g;g++){f=i[g];e=a.id(f.hash.slice(1));if(!--e.dataset.forwarded){a.rmClass(e.pN(),"forwarded")}}if(/\bbacklink\b/.test(c.className)){e=a.id("p"+d);if(!--e.dataset.forwarded){return a.rmClass(e.pN(),"forwarded")}}}};i={init:function(){return e.callbacks.push(this.node)},node:function(b){var c,d=_j=0,e=b.quotes,f=b.backlinks;for(;e.length>d;d++){c=e[d];if(c.hash||/\bdeadlink\b/.test(c.className)){a.on(c,"mouseover",i.mouseover)}}for(;f.length>_j;_j++){a.on(f[_j],"mouseover",i.mouseover)}},mouseover:function(e){var f,g=this.hash.slice(2),h,j,l,m=0,n;if(/\binlined\b/.test(this.className)){return}if(h=a.id("qp")){if(h===k.el){delete k.el}a.rm(h)}if(k.el){return}h=k.el=a.el("div",{id:"qp",className:"reply dialog"});k.hover(e);a.add(d.body,h);f=a.id("p"+g);c.post(g,h);a.on(this,"mousemove",k.hover);a.on(this,"mouseout click",i.mouseout);if(!f){return}if(/\bop\b/.test(f.className)){a.addClass(f.pN(),"qphl")}else{a.addClass(f,"qphl")}l=a.x("ancestor::*[@id][1]",this).id.match(/\d+$/)[0];n=b(".quotelink, .backlink",h);for(;n.length>m;m++){j=n[m];if(j.hash.slice(2)===l){a.addClass(j,"forwardlink")}}},mouseout:function(b){var c;k.hoverend();if(c=a.id(this.hash.slice(1))){a.rmClass(c,"qphl");a.rmClass(c.pN(),"qphl")}a.off(this,"mousemove",k.hover);return a.off(this,"mouseout click",i.mouseout)}};m={init:function(){return e.callbacks.push(this.node)},node:function(b){if(!b.img){return}return a.on(b.img,"mouseover",m.mouseover)},mouseover:function(){var b,c;if(b=a.id("ihover")){if(b===k.el){delete k.el}a.rm(b)}if(k.el){return}c={id:'ihover',src:this.pN().href};c.src.reverse().iO('m')==0&&a.extend(c,{autoplay:true,loop:true});b=k.el=a.el(c.loop?'video':'img',c);a.add(d.body,b);a.on(b,"load",m.load);a.on(this,"mousemove",k.hover);return a.on(this,"mouseout",m.mouseout)},load:function(){var a;if(!this.pN()){return}a=this.style;return k.hover({clientX:-45+parseInt(a.left),clientY:120+parseInt(a.top)})},mouseout:function(){k.hoverend();a.off(this,"mousemove",k.hover);return a.off(this,"mouseout",m.mouseout)}};o={videos:[],init:function(){return e.callbacks.push(this.node);a.on(window,'resize scroll visibilitychange',o.videoHandler)},node:function(b){if(!b.img){return}return a.on(b.img.pN(),'click',o.cb.toggle)},cb:{toggle:function(e){if(e.shiftKey||e.altKey||e.ctrlKey||e.metaKey||e.button!==0){return}e.preventDefault();return o.toggle(this)}},toggle:function(b){var c,e=b.firstChild;if(e.hidden){c=b.getBoundingClientRect();if(d.body.gA("class")!=='i'){if(c.top<0){d.body.scrollTop+=c.top-42}if(c.left<0){d.body.scrollLeft+=c.left}}else{if(c.top<0){dE.scrollTop+=c.top-42}if(c.left<0){dE.scrollLeft+=c.left}}return o.contract(e)}else{return o.expand(e)}},contract:function(b){var c=b.nextSibling,d;b.hidden=false;c.hidden=true;if(c.loop){d=o.videos;d=d.splice(d.indexOf(a.rm(c)),1)}},expand:function(b){var c,d,e,f;if(a.x('ancestor-or-self::*[@hidden]',b)){return}b.hidden=true;if((d=b.nextSibling)&&(d.nodeName=='IMG'||(e=d.nodeName =='VIDEO'))){d.hidden=false;e&&d.play();return}c=b.pN();f=c.href;d=f.reverse().iO('m')==0?a.el('video',{src:f,autoplay:!0,loop:!0}):a.el('img',{src:f,style: 'width:100px;height:100px;'});if(d.loop){o.videos.push(d);a.on(d,'canplay',o.videoHandler)}else{!d.naturalWidth?a.on(d,'load',function(){d.removeAttribute("style")}):d.removeAttribute("style")}return a.add(c,d)},videoHandler:function(){var b,c=o.videos,v;for(b=0;c.length>b;b++){v=c[b];a.visible(v)&&!d.hidden?v.play():v.pause()}}};e={init:function(){(function(){var c=b('a.fileThumb'),i=0;/WebKit/.test(navigator.userAgent)||s(d.body,'class','i');for(;c.length>i;i++){var n=a.nodes([a.tn(' '),a.el('a',{textContent:'google',href:'http://www.google.com/searchbyimage?image_url='+c[i].href,target:'_blank'})]);-1!==location.protocol.iO('http')&&c[i].previousElementSibling.appendChild(n)}for(c=b('span.abbr a'),i=0;c.length>i;i++){s(c[i],'onclick','javascript:e=this.pN().pN().lastChild.style;e.display=e.display=="block"?"none":"block"')}}());a.add(a("div.navLinks"),[a.tn(" ["),a.el("a",{href:"javascript:;",textContent:"QuotePreview is "+(l?"ON":"OFF"),onclick:function(){lS.qp_opt=l?0:1;window.location.reload()}}),a.tn("] ["),a.el("a",{href:"javascript:;",textContent:"ImageHover is "+(n?"ON":"OFF"),onclick:function(){lS.img_hover=n?0:1;window.location.reload()}}),a.tn("] ["),a.el("a",{href:"./"+window.location.href.split("/").pop().split(".")[0]+"/misc/gallery.html",textContent:"Image only view"}),a.tn("]")]);j.init();h.init();l&&i.init();n&&m.init();o.init();g.init();e.ready()},ready:function(){var c=[],d=0,f=b(".postContainer",a.id("delform"));for(;f.length>d;d++){c.push(e.preParse(f[d]))}e.node(c);if(MutationObserver=window.MutationObserver||window.WebKitMutationObserver||window.OMutationObserver){observer=new MutationObserver(e.observer);observer.observe(a(".board"),{childList:true,subtree:true})}else{a.on(a(".board"),"DOMNodeInserted",e.listener)}},preParse:function(c){var d=a(".post",c),e=c.pN().className,f={root:c,el:d,"class":d.className,ID:d.id.match(/\d+$/)[0],threadID:a.x("ancestor::div[parent::div[@class='board']]",c).id.match(/\d+$/)[0],isInlined:/\binline\b/.test(e),blockquote:d.lastElementChild,quotes:b("a.quotelink[href^='#p']",d),backlinks:d.getElementsByClassName("backlink"),img:false},g;if(g=a('img[data-md5]',d)){f.img=g}return f},node:function(a){for(var b=0,c=e.callbacks;c.length>b;b++){var d=c[b];try{for(var f=0;a.length>f;f++){d(a[f])}}catch(g){alert("Error: "+g.message+"\nReport the bug to HandyAnon@Steam\n\nURL: "+window.location+"\n"+g.stack)}}},observer:function(a){var b,c,d,f,g,h,i,j;d=[];for(f=0,h=a.length;h>f;f++){c=a[f];j=c.addedNodes;for(g=0,i=j.length;i>g;g++){b=j[g];if(/\bpostContainer\b/.test(b.className)){d.push(e.preParse(b))}}}if(d.length){return e.node(d)}},listener:function(a){var b;b=a.target;if(/\bpostContainer\b/.test(b.className)){return e.node([e.preParse(b)])}},callbacks:[]};a.on(d,"DOMContentLoaded",e.init)}).call(this)//]]></script><style>/*<![CDATA[*/img[data-md5]+*{max-width:100%!important;}.i img[data-md5]+*{width:100%!important;}.op:after{clear:both;content:'';display:block;}#qp{padding:2px 2px 5px;position:fixed;border:1px solid rgba(128,128,128,0.5);}#qp .post{border:none;margin:0;padding:0;}#qp img,#qp video{max-height:300px;max-width:500px;}.qphl{outline:2px solid rgba(216,94,49,.7);}.inlined{opacity:.5;}.inline{border:1px solid rgba(128,128,128,0.5);display:table;margin:2px;padding:2px;}.inline .post{background:none;border:none;margin:0;padding:0;}.forwarded{display:none;}.quotelink.forwardlink,.backlink.forwardlink{text-decoration:none;border-bottom:1px dashed;}#ihover{max-height:97%;max-width:75%;padding-bottom:18px;position:fixed;} blockquote{word-wrap:break-word;min-width:120px;}/*]]>*/</style>
EOF

	tail -n1 a >> $LOC.html

	rm a

	sed -i -e '1 {s_<script_!>\n&_
		s_<link [^>]*RSS feed[^>]*>__
		s@//'$ST'/image/\(favicon[^.]*\.ico\)@'$LOC'/misc/\1@
		s_<link rel="alternate style[^-]*\(<link[^>]*tomorrow\.[^>]*>\)<link[^>]*>_\1_
		s@//'$ST'/css/\([^.]\+\.[^.]\+\.css\)@'$LOC'/misc/\1@g}' -e '$ {s_</head>_<!&_
		s_<div id="boardNavDesktop" class="desktop">_\n_
		s_<div class="boardBanner"_\n<!&_
  s@ data-src="[^.]\+\.\([^"]\+\)">@><img alt="4chan" src="'$LOC'/misc/logo.\1" />@
		s_<hr class="abovePost_\n_
		s_ .<a[^>]*>Catalog</a>.__g
		s_\(<div class="navLinks desktop">.<a href="/[^/]\+/[^#]*\)#bottom\(">Bottom</a>.\)_\n<!\1javascript:dE.scrollIntoView(false)\2</div><hr>\n_
		s_\(<form name="delform" id="delform"\)[^>]*_\n<!\1_
		s@//.\.t\.4cdn\.org/[^/]*/\([0-9]*s\.jpg\)@'$LOC'/misc/\1@g
		s@//i\.4cdn\.org/[^/]*/\([0-9]*\....\)@'$LOC'/\1@g
		s@//'$ST'/image/title/[a-z0-9-]*\.\(...\)@'$LOC'/misc/logo.\1@g
		s@//'$ST'/image/\(spoiler[^.]*\....\)@'$LOC'/misc/\1@g
		s@//'$ST'/image/\(filedeleted-res\.gif\)@'$LOC'/misc/\1@g
		s@//'$ST'/image/country/\([^.]*\....\)@'$LOC'/misc/\1@g
		s@//'$ST'/image/\([a-z]*icon.gif\)@'$LOC'/misc/\1@g
		s_<div data.tip[^>]*>[^<]*<div>__g
		s_\(<a href="\)'$NO'#p_\1#p_g
		s_<a href="#p'$NO'"[^>]*>&gt;&gt;'$NO'_& (OP)_g
		s:\(<a href="\)\([0-9]\+\)\(#p[0-9]*\)\([^<]*\):\1'$BO'_\2.html" target="_blank" \3 (Cross-thread):g
		s_\(<div class="navLinks navLinksBot desktop">.<a href="/[^/]\+/"[^>]*>Return</a>. .<a href="\)#top\(">Top</a>.\)_\n<!<span style="float:right;">Style: [ <a href="javascript:sT(1);dE.scrollIntoView(false)">Default</a> | <a href="javascript:sT(0);dE.scrollIntoView(false)">Tomorrow</a> ]</span>\1javascript:dE.scrollIntoView()\2\n_
		s@</body>@\n<!</div></div></form>&@}' -e '{s:\(<a href="\)/./\([^>]*>Return</a>\):\1'"$RET"'\2:g
		s_\(<a[^>]*href="\)//_\1http://_g
		s_\(<a[^>]*\) onclick="replyhl[^"]*"_\1_g
		s_\(<a href="javascript:\)quote[^>]*_\1;"_g
		s_<div class="postInfoM_\n_g
		s_<div class="file"_\n<!&_g
		s_<div class="postInfo _\n<!&_g
		s_<a href="/ic\?/anim\.php?file=[0-9]*" target="\_blank">_<a title="View is supported only on 4chan">_g
		s_\(<input type="checkbox"\)[^>]*_\1_g
		s_<a onclick="toggle..exif[^"]*"_<a_g
		s_<div class="mFileInfo mobile">[^<]*</div>__g
		s_<wbr>__g}' $LOC.html

	grep '^<!' $LOC.html > a

	sed -i -e '2,$ s_^<!__' a

	tr -d '\n' < a > $LOC.html

	sed -i -e 's_!>_\n_g' $LOC.html

	rm a

	cd $LOC/misc

	CSS=$(basename `head -n1 css`)

	if [ "$CSSt" != "$CSS" ]; then
		CSSt=CSS
		if [ "$(ls|grep '.css')" ]; then
			rm *.css
		fi
		wget -q -nc -i css
		wget -q -nc "$(grep -o 'fade[^.]*\.png' $CSS | sed -e 's_.*_http://'$ST'/image/&_')"
		sed -i -e 's_/image/\(fade[^.]*\.png\)_\1_g' $CSS
	fi

	if [ "$(ls|grep logo.)" ]; then
		rm "$(ls|grep logo.|head -n1)"
	fi

	wget -q -i logo -O "logo.$(sed 's_\._\n_g' logo|tail -n1)"

	rm logo css

	touch .nomedia

 cd ..

	for image in $(cat images); do
		wget -q -nc $image
	done

	rm images

	cd misc

	for misc in $(cat misc); do
		wget -q -nc $misc
	done

 rm misc

	cd ../..
}

exito () {
	echo "Session completed. Exiting"
	exit 0
}

echo ""
echo "Downloading to $LOC"
echo "------------------------------"

while true; do
	trap exito 1 2 3 15

	stat="$(wget -S --spider "$URL" 2>&1)"

	if [ "$(echo "$stat" |grep '404 Not Found')" ]; then
		if [ -s $LOC.html ]; then
			echo "Thread has 404'd or 4chan is down. Stopping script"
		else
			echo "Thread does not exist. Stopping script"
		fi
		exit 0
	fi

	if [ "$LM" != "$(echo "$stat" |grep Last-Modified)" ]; then
		LM="$(echo "$stat" |grep Last-Modified)"
		if [ $SLP -gt 1 ] && [ $SLP -lt 10 ]; then
			$SLP="10"
		elif [ $SLP -gt 999 ]; then
			$SLP="999"
		elif [ $SLP -lt 1 ]; then
			$SLP="1"
		fi
		SLAP=$SLP
		wget -np -nd -nH -q -erobots=off $URL -O $LOC.html
		thejob
	else
		SLAP=`expr "$SLAP" + "5"`
	fi

	trap - 1 2 3 15

	if [ $SLP = "1" ]; then
		exito
	fi

	echo -ne OK

	sleep $SLAP

	echo -ne "\b\b  \b\b"
done
