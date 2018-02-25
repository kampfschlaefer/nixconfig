from setuptools import setup

setup(
    name='dash_button',
    version='0.2',
    description='The funniest joke in the world',
    # url='http://github.com/storborg/funniest',
    # author='Flying Circus',
    # author_email='flyingcircus@example.com',
    license='MIT',
    packages=['dash_button'],
    entry_points={
        'console_scripts': [
            'dash_button_daemon=dash_button.dash_button:run',
            'dash_button_test=dash_button.test_button:run',
        ]
    },
    install_requires=[
        'homeassistant',
        'scapy==2.4.0rc4',
    ],
    zip_safe=False
)
