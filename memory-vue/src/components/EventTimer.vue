<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps<{
  eventDate: string
  updateInterval?: number
  simple?: boolean
  onDarkBackground?: boolean
  textColor?: string
}>()

// Default update interval is 60 seconds for list view (less resource intensive)
const defaultInterval = props.simple === true ? 60000 : 1000

// Time since event
const timeSinceEvent = ref('Calculating...')
const timer = ref<number | null>(null)

// Calculate time since event
function calculateTimeSince() {
  const eventDate = new Date(props.eventDate)
  const now = new Date()
  
  const diffInMs = now.getTime() - eventDate.getTime()
  
  // For debugging
  console.log('Vue Timer: Calculating time since event', props.eventDate, diffInMs / 1000, 'seconds')
  
  // Convert to appropriate units
  const seconds = Math.floor(diffInMs / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)
  const months = Math.floor(days / 30.4375) // Average month length
  const years = Math.floor(days / 365.25) // Account for leap years
  
  if (props.simple) {
    // Simplified version for list view
    if (years > 0) {
      timeSinceEvent.value = `${years}y`
      if (years < 10 && months % 12 > 0) {
        const remainingMonths = Math.floor((days - (years * 365.25)) / 30.4375)
        if (remainingMonths > 0) {
          timeSinceEvent.value += ` ${remainingMonths}m`
        }
      }
    } else if (months > 0) {
      timeSinceEvent.value = `${months}m`
      if (months < 10) {
        const remainingDays = Math.floor(days - (months * 30.4375))
        if (remainingDays > 0) {
          timeSinceEvent.value += ` ${remainingDays}d`
        }
      }
    } else if (days > 0) {
      timeSinceEvent.value = `${days}d`
    } else if (hours > 0) {
      timeSinceEvent.value = `${hours}h`
    } else if (minutes > 0) {
      timeSinceEvent.value = `${minutes}m`
    } else {
      timeSinceEvent.value = `${seconds}s`
    }
  } else {
    // Detailed version for detail view
    if (years > 0) {
      const remainingMonths = Math.floor((days - (years * 365.25)) / 30.4375)
      timeSinceEvent.value = `${years} year${years !== 1 ? 's' : ''}`
      if (remainingMonths > 0) {
        timeSinceEvent.value += `, ${remainingMonths} month${remainingMonths !== 1 ? 's' : ''}`
      }
    } else if (months > 0) {
      const remainingDays = Math.floor(days - (months * 30.4375))
      timeSinceEvent.value = `${months} month${months !== 1 ? 's' : ''}`
      if (remainingDays > 0) {
        timeSinceEvent.value += `, ${remainingDays} day${remainingDays !== 1 ? 's' : ''}`
      }
    } else if (days > 0) {
      const remainingHours = hours - (days * 24)
      timeSinceEvent.value = `${days} day${days !== 1 ? 's' : ''}`
      if (remainingHours > 0) {
        timeSinceEvent.value += `, ${remainingHours} hour${remainingHours !== 1 ? 's' : ''}`
      }
    } else if (hours > 0) {
      const remainingMinutes = minutes - (hours * 60)
      timeSinceEvent.value = `${hours} hour${hours !== 1 ? 's' : ''}`
      if (remainingMinutes > 0) {
        timeSinceEvent.value += `, ${remainingMinutes} minute${remainingMinutes !== 1 ? 's' : ''}`
      }
    } else if (minutes > 0) {
      const remainingSeconds = seconds - (minutes * 60)
      timeSinceEvent.value = `${minutes} minute${minutes !== 1 ? 's' : ''}`
      if (remainingSeconds > 0) {
        timeSinceEvent.value += `, ${remainingSeconds} second${remainingSeconds !== 1 ? 's' : ''}`
      }
    } else {
      timeSinceEvent.value = `${seconds} second${seconds !== 1 ? 's' : ''}`
    }
  }
}

onMounted(() => {
  // Initial calculation
  calculateTimeSince()
  
  // Set up interval to update
  timer.value = window.setInterval(
    calculateTimeSince, 
    props.updateInterval || defaultInterval
  )
})

onUnmounted(() => {
  // Clean up interval
  if (timer.value !== null) {
    clearInterval(timer.value)
  }
})
</script>

<template>
  <span class="event-timer" :class="{ 'timer-on-dark': props.onDarkBackground }">
    <slot>
      <v-icon 
        icon="mdi-clock-outline" 
        size="x-small" 
        class="mr-1"
        :color="props.textColor || (props.onDarkBackground ? 'white' : 'primary')"
      ></v-icon>
      {{ timeSinceEvent }}
    </slot>
  </span>
</template>

<style scoped>
.event-timer {
  display: inline-flex;
  align-items: center;
  white-space: nowrap;
  color: v-bind('props.textColor || (props.onDarkBackground ? "white" : "primary")');
  font-weight: 500;
}

.timer-on-dark {
  color: white;
}
</style>