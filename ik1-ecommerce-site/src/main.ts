import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { i18n } from './i18n'
import './assets/style/main.css'
import theFooter from './componets/layout/theFooter.vue'
import theHeader from './componets/layout/theHeader.vue'

const app = createApp(App)
app.component('the-header', theHeader)
app.component('the-footer', theFooter)

app.use(createPinia())
app.use(router)
app.use(i18n)

app.mount('#app')
