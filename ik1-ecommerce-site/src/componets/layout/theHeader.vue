<template>
  <header>
    <p>{{ $t('welcome') }}</p>
    <div class="bg-white dark:bg-gray-900 min-h-screen text-black dark:text-white">
      <button @click="toggleTheme" class="p-2 border">{{ themeMode }}</button>
      <button @click="changeLang('en')">EN</button>
      <button @click="changeLang('ar')">AR</button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { locale } = useI18n()

const dark = ref(false)
const themeMode = ref('dark')

onMounted(() => {
  dark.value = localStorage.getItem('theme') === 'dark'
  themeMode.value = localStorage.getItem('theme') || 'dark'
  document.documentElement.classList.toggle('dark', dark.value)
})
const changeLang = (lang) => {
  locale.value = lang
}
const toggleTheme = () => {
  dark.value = !dark.value
  localStorage.setItem('theme', dark.value ? 'dark' : 'light')
  themeMode.value = !dark.value ? 'dark' : 'light'
  document.documentElement.classList.toggle('dark', dark.value)
}
</script>

<style scoped></style>
