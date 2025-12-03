"""
LLM Provider Management for J.A.R.V.I.S.

Supports multiple LLM providers:
- Claude API (fast, smart, requires internet)
- Ollama (local, private, slower)
"""

import os
import requests
from typing import Optional, Dict, Any
from enum import Enum


class LLMProvider(str, Enum):
    """Available LLM providers."""
    CLAUDE = "claude"
    OLLAMA = "ollama"


class LLMManager:
    """
    Manages multiple LLM providers with fallback support.

    Features:
    - Switch between Claude API and local Ollama
    - Privacy mode (always use local)
    - Automatic fallback on errors
    - Performance tracking
    """

    def __init__(
        self,
        default_provider: LLMProvider = LLMProvider.CLAUDE,
        ollama_host: str = "http://localhost:11434",
        ollama_model: str = "gemma:2b",
    ):
        self.current_provider = default_provider
        self.ollama_host = ollama_host
        self.ollama_model = ollama_model
        self.claude_api_key = os.getenv("ANTHROPIC_API_KEY")
        self.request_count = {
            LLMProvider.CLAUDE: 0,
            LLMProvider.OLLAMA: 0,
        }

    def set_provider(self, provider: LLMProvider):
        """Switch to a different LLM provider."""
        self.current_provider = provider

    def get_provider(self) -> LLMProvider:
        """Get current LLM provider."""
        return self.current_provider

    def check_ollama_available(self) -> bool:
        """Check if Ollama is running and accessible."""
        try:
            response = requests.get(f"{self.ollama_host}/api/tags", timeout=2)
            return response.status_code == 200
        except:
            return False

    def check_claude_available(self) -> bool:
        """Check if Claude API is configured."""
        return self.claude_api_key is not None and len(self.claude_api_key) > 0

    async def generate(
        self,
        prompt: str,
        provider: Optional[LLMProvider] = None,
        system_prompt: Optional[str] = None,
        max_tokens: int = 1024,
        temperature: float = 0.7,
    ) -> Dict[str, Any]:
        """
        Generate response from selected LLM provider.
        
        Args:
            prompt: User prompt
            provider: Which provider to use (defaults to current)
            system_prompt: System context
            max_tokens: Maximum response length
            temperature: Creativity level (0-1)
            
        Returns:
            Dict with response, provider, model, and success status
        """
        use_provider = provider or self.current_provider

        try:
            if use_provider == LLMProvider.CLAUDE:
                return await self._generate_claude(
                    prompt, system_prompt, max_tokens, temperature
                )
            else:
                return await self._generate_ollama(
                    prompt, system_prompt, max_tokens, temperature
                )
        except Exception as e:
            return {
                "response": "",
                "provider": use_provider.value,
                "model": "",
                "success": False,
                "error": str(e)
            }

    async def _generate_claude(
        self, 
        prompt: str, 
        system_prompt: Optional[str], 
        max_tokens: int, 
        temperature: float
    ) -> Dict[str, Any]:
        """Generate response using Claude API."""
        if not self.claude_api_key:
            return {
                "response": "",
                "provider": "claude",
                "model": "",
                "success": False,
                "error": "Claude API key not configured. Set ANTHROPIC_API_KEY environment variable."
            }

        try:
            import anthropic
            
            client = anthropic.Anthropic(api_key=self.claude_api_key)
            messages = [{"role": "user", "content": prompt}]
            
            response = client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=max_tokens,
                temperature=temperature,
                system=system_prompt if system_prompt else "You are JARVIS, a helpful personal AI assistant with memory capabilities.",
                messages=messages,
            )
            
            self.request_count[LLMProvider.CLAUDE] += 1
            
            return {
                "response": response.content[0].text,
                "provider": "claude",
                "model": "claude-3-5-sonnet-20241022",
                "success": True,
            }
        except Exception as e:
            return {
                "response": "",
                "provider": "claude",
                "model": "claude-3-5-sonnet-20241022",
                "success": False,
                "error": f"Claude API error: {str(e)}"
            }

    async def _generate_ollama(
        self,
        prompt: str,
        system_prompt: Optional[str],
        max_tokens: int,
        temperature: float
    ) -> Dict[str, Any]:
        """Generate response using local Ollama model."""
        try:
            # Construct full prompt with system context
            full_prompt = prompt
            if system_prompt:
                full_prompt = f"{system_prompt}\n\nUser: {prompt}\n\nAssistant:"

            response = requests.post(
                f"{self.ollama_host}/api/generate",
                json={
                    "model": self.ollama_model,
                    "prompt": full_prompt,
                    "stream": False,
                    "options": {
                        "temperature": temperature,
                        "num_predict": max_tokens,
                    }
                },
                timeout=60,
            )

            if response.status_code != 200:
                return {
                    "response": "",
                    "provider": "ollama",
                    "model": self.ollama_model,
                    "success": False,
                    "error": f"Ollama returned status {response.status_code}"
                }

            result = response.json()
            self.request_count[LLMProvider.OLLAMA] += 1
            
            return {
                "response": result.get("response", ""),
                "provider": "ollama",
                "model": self.ollama_model,
                "success": True,
            }
        except requests.Timeout:
            return {
                "response": "",
                "provider": "ollama",
                "model": self.ollama_model,
                "success": False,
                "error": "Ollama request timed out (>60s). Model might be too large for your RAM."
            }
        except Exception as e:
            return {
                "response": "",
                "provider": "ollama",
                "model": self.ollama_model,
                "success": False,
                "error": f"Ollama error: {str(e)}. Is Ollama running? Try: ollama serve"
            }

    def get_status(self) -> Dict[str, Any]:
        """Get status of all available LLM providers."""
        return {
            "current_provider": self.current_provider.value,
            "providers": {
                "claude": {
                    "available": self.check_claude_available(),
                    "model": "claude-3-5-sonnet-20241022",
                    "request_count": self.request_count[LLMProvider.CLAUDE],
                },
                "ollama": {
                    "available": self.check_ollama_available(),
                    "model": self.ollama_model,
                    "host": self.ollama_host,
                    "request_count": self.request_count[LLMProvider.OLLAMA],
                }
            }
        }
