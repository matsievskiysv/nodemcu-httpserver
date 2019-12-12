async function draw_plot(endpoint, element_id, title, low, high) {
    var data = await (await fetch(endpoint)).json();
    for(var i = data.y.length - 1; i >= 0; i--) {
	if(data.y[i] <= low || data.y[i] >= high) {
	    data.x.splice(i, 1);
	    data.y.splice(i, 1);
	}
    }
    var plot = document.getElementById(element_id);
    if (typeof Plotly !== "undefined") {
	Plotly.react(plot, [data],
		     {title: title,
		      font: {size: 18}},
		     {responsive: true});
    } else {
	var html_list = `<h3>${title}</h3>\n`;
	html_list = html_list + "<table>\n";
	for (var i = 0, size = data.x.length; i < size; i++) {
	    html_list = html_list + "<tr>\n";
	    html_list = html_list + `<th>${data.x[i].toFixed(2)}</th>\n`;
	    html_list = html_list + `<th>${data.y[i].toFixed(2)}</th>\n`;
	    html_list = html_list + "</tr>\n";
	}
	html_list = html_list + "</table>\n";
	plot.innerHTML = html_list;
    };
}
setTimeout(() => {draw_plot("/get.lua?temp=1", "plot_temp", "Temperature", 0, 100);}, 1500)
setTimeout(() => {draw_plot("/get.lua?humid=1", "plot_humid", "Humidity", 0, 100);}, 3000)
var timer_temp, timer_humid;

function update_temp(elem) {
    if (elem.checked) {
	draw_plot("/get.lua?temp=1", "plot_temp", "Temperature", 0, 100);
	timer_temp = setInterval(() => {draw_plot("/get.lua?temp=1", "plot_temp", "Temperature", 0, 100);}, 300000);
    } else {
	clearInterval(timer_temp);
    }
}

function update_humid(elem) {
    if (elem.checked) {
	draw_plot("/get.lua?humid=1", "plot_humid", "Humidity", 0, 100);
	timer_humid = setInterval(() => {draw_plot("/get.lua?humid=1", "plot_humid", "Humidity", 0, 100);}, 300000);
    } else {
	clearInterval(timer_humid);
    }
}
