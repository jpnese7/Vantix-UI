// Handle Tab Switching
const sidebarItems = document.querySelectorAll('.sidebar-item');
const tabContents = document.querySelectorAll('.tab-content');

sidebarItems.forEach(item => {
    item.addEventListener('click', () => {
        const tabName = item.getAttribute('data-tab');
        
        // Update active sidebar item
        sidebarItems.forEach(i => i.classList.remove('active'));
        item.classList.add('active');
        
        // Show correct tab content
        tabContents.forEach(content => {
            content.classList.remove('active');
            if (content.id === `tab-${tabName}`) {
                content.classList.add('active');
            }
        });
    });
});

// Handle Slider Value Update
const slider = document.querySelector('.slider');
const sliderValue = document.querySelector('.slider-value');

if (slider) {
    slider.addEventListener('input', (e) => {
        sliderValue.textContent = e.target.value;
    });
}

// Copy Code Functionality
function copyCode() {
    const loadstring = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/AntigravityLib.lua"))()';
    navigator.clipboard.writeText(loadstring).then(() => {
        const btn = document.querySelector('.btn-secondary');
        const originalText = btn.textContent;
        btn.textContent = 'Copied!';
        btn.style.borderColor = '#4ade80';
        setTimeout(() => {
            btn.textContent = originalText;
            btn.style.borderColor = '';
        }, 2000);
    });
}

function copyFullCode() {
    const code = document.querySelector('.code-block code').textContent;
    navigator.clipboard.writeText(code).then(() => {
        const btn = document.querySelector('.copy-btn');
        const originalHtml = btn.innerHTML;
        btn.innerHTML = '<i data-lucide="check"></i>';
        lucide.createIcons();
        setTimeout(() => {
            btn.innerHTML = originalHtml;
            lucide.createIcons();
        }, 2000);
    });
}

// GUI Window Animation on Scroll
window.addEventListener('scroll', () => {
    const windowEl = document.querySelector('.roblox-window');
    if (windowEl) {
        const rect = windowEl.getBoundingClientRect();
        if (rect.top < window.innerHeight) {
            windowEl.style.opacity = '1';
            windowEl.style.transform = 'translateY(0)';
        }
    }
});
