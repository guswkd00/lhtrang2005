// Chức năng chuyển ngữ
const langViBtn = document.getElementById('langVi');
const langEnBtn = document.getElementById('langEn');
const langTexts = document.querySelectorAll('.lang-text');
const langPlaceholders = document.querySelectorAll('.lang-placeholder');

langViBtn.addEventListener('click', () => {
    langViBtn.classList.add('active');
    langEnBtn.classList.remove('active');
    updateLanguage('vi');
});

langEnBtn.addEventListener('click', () => {
    langEnBtn.classList.add('active');
    langViBtn.classList.remove('active');
    updateLanguage('en');
});

function updateLanguage(lang) {
    // Cập nhật text
    langTexts.forEach(element => {
        const text = element.getAttribute(`data-${lang}`);
        if (text) element.textContent = text;
    });
    
    // Cập nhật placeholder
    langPlaceholders.forEach(element => {
        const placeholder = element.getAttribute(`data-${lang}`);
        if (placeholder) element.placeholder = placeholder;
    });
}

// Xử lý form khảo sát
document.getElementById('surveyForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const formData = {
        name: document.getElementById('fullName').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        // Thêm các trường khác
    };
    
    // Gửi đến backend
    try {
        const response = await fetch('http://localhost:5000/api/survey', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });
        
        if (response.ok) {
            alert('Cảm ơn bạn đã tham gia khảo sát!');
            this.reset();
        }
    } catch (error) {
        console.error('Error:', error);
    }
});