Vue.config.productionTip = false
Vue.config.devtools = false

let app = new Vue({
    el: "#drift",
  
    data: {
        driftCount: 0,
        show: false,
        driftCountn: 0,
    },

    methods: {
        atualizeDrift(driftPoints){
            function numberWithCommas(x) {
                return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
            this.driftCountn = driftPoints
            this.driftCount = driftPoints.toLocaleString()
        }
    },
})

window.addEventListener('message',function(event){
    var item = event.data.drift;
    app.atualizeDrift(item)
});