
import React from "react";
import { Link } from "react-router-dom";

const FooterSection = () => {
  return (
    <footer className="bg-black text-white py-12">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10">
          <div>
            <div className="flex items-center mb-6">
              <img 
                src="https://logodetimes.com/wp-content/uploads/flamengo.png" 
                alt="NetoTours" 
                className="h-12 mr-3"
              />
              <h3 className="text-xl font-bold">NetoTours</h3>
            </div>
            <p className="text-gray-400 mb-4">
              Realizando sonhos rubro-negros desde 2015. Excursões oficiais para jogos do Flamengo.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="text-gray-400 hover:text-red-600">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                  <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"></path>
                </svg>
              </a>
              <a href="#" className="text-gray-400 hover:text-red-600">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                  <rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect>
                  <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path>
                  <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line>
                </svg>
              </a>
              <a href="#" className="text-gray-400 hover:text-red-600">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                  <path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"></path>
                </svg>
              </a>
            </div>
          </div>
          
          <div>
            <h3 className="text-lg font-bold mb-4">Links Rápidos</h3>
            <ul className="space-y-2">
              <li>
                <a href="#next-trips" className="text-gray-400 hover:text-white">Próximas Viagens</a>
              </li>
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Sobre Nós</a>
              </li>
              <li>
                <Link to="/cadastro-publico" className="text-gray-400 hover:text-white">Cadastre-se</Link>
              </li>
              <li>
                <Link to="/login" className="text-gray-400 hover:text-white">Área do Cliente</Link>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-bold mb-4">Políticas</h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Termos de Serviço</a>
              </li>
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Política de Privacidade</a>
              </li>
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Política de Reembolso</a>
              </li>
              <li>
                <a href="#" className="text-gray-400 hover:text-white">FAQ</a>
              </li>
            </ul>
          </div>
        </div>
        
        <div className="border-t border-gray-800 mt-10 pt-8 text-center text-gray-500 text-sm">
          <p>&copy; {new Date().getFullYear()} NetoTours. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>
  );
};

export default FooterSection;
