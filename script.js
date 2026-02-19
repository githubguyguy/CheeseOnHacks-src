// Tab switching functionality
document.querySelectorAll('.script-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const scriptId = btn.getAttribute('data-script');
        
        // Remove active class from all buttons and tabs
        document.querySelectorAll('.script-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.script-tab').forEach(tab => tab.classList.remove('active'));
        
        // Add active class to clicked button and corresponding tab
        btn.classList.add('active');
        document.getElementById(scriptId).classList.add('active');
    });
});

// Add subtle glow effect on mouse move
document.addEventListener('mousemove', (e) => {
    const x = e.clientX / window.innerWidth;
    const y = e.clientY / window.innerHeight;
    
    document.querySelectorAll('.script-btn').forEach(btn => {
        const rect = btn.getBoundingClientRect();
        const distance = Math.sqrt(
            Math.pow(e.clientX - (rect.left + rect.width / 2), 2) +
            Math.pow(e.clientY - (rect.top + rect.height / 2), 2)
        );
        
        if (distance < 200) {
            btn.style.boxShadow = `0 0 ${20 - distance / 10}px rgba(0, 255, 65, ${0.5 - distance / 400})`;
        }
    });
});

// Smooth scrolling for sidebar and content
const sidebar = document.querySelector('.sidebar');
const content = document.querySelector('.content');

if (sidebar) {
    sidebar.addEventListener('scroll', () => {
        sidebar.style.boxShadow = '0 0 20px rgba(0, 255, 65, 0.2), inset 0 0 20px rgba(0, 255, 65, 0.05)';
    });
}

if (content) {
    content.addEventListener('scroll', () => {
        content.style.boxShadow = '0 0 20px rgba(0, 255, 65, 0.2), inset 0 0 20px rgba(0, 255, 65, 0.05)';
    });
}

// Initialize first tab as active
window.addEventListener('load', () => {
    const firstBtn = document.querySelector('.script-btn');
    if (firstBtn) {
        firstBtn.click();
    }
});
